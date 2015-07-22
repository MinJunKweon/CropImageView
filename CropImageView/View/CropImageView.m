//
//  CropImageView.m
//  CropImageView
//
//  Created by 1000732 on 2015. 7. 22..
//  Copyright (c) 2015년 1000732. All rights reserved.
//

#import "CropImageView.h"

@interface CropImageView ()

@property (nonatomic) CGSize originSize;

@property (nonatomic) CGFloat previousRotationAngle;
@property (nonatomic) CGFloat previousPinchScale;
@property (nonatomic) CGPoint previousPanTranslation;

@property (nonatomic) CGFloat resultRotationAngle;
@property (nonatomic) CGFloat resultPinchScale;
@property (nonatomic) CGPoint resultPanTraslation;

@property (nonatomic) CGPoint leftTopPoint;
@property (nonatomic) CGPoint rightBottomPoint;

@end

@implementation CropImageView

#pragma mark - Initializer

- (instancetype)init
{
    return [self initWithImage:nil];
}

- (instancetype)initWithImage:(UIImage *)image
{
    return [self initWithImage:image maximumScale:0.0f];
}

- (instancetype)initWithImage:(UIImage *)image maximumScale:(CGFloat)maximumScale
{
    self = [super initWithImage:image];
    if (self) {
        _maximumScale = maximumScale;
        _previousRotationAngle = 0.0f;
        _previousPinchScale = 1.0f;
        _previousPanTranslation = CGPointMake(0, 0);
        
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.multipleTouchEnabled = YES;
        self.userInteractionEnabled = YES;
        
        UIRotationGestureRecognizer *rotationGestureRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotate:)];
        rotationGestureRecognizer.delegate = self;
        UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
        pinchGestureRecognizer.delegate = self;
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleMove:)];
        panGestureRecognizer.delegate = self;
        [self addGestureRecognizer:rotationGestureRecognizer];
        [self addGestureRecognizer:pinchGestureRecognizer];
        [self addGestureRecognizer:panGestureRecognizer];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _originSize = self.bounds.size;
    _leftTopPoint = self.bounds.origin;
    _rightBottomPoint = CGPointMake(_originSize.width, _originSize.height);
}

#pragma mark - Gesture Recognizer

- (void)handleRotate:(UIRotationGestureRecognizer *)rotationGestureRecognizer
{
    if (rotationGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat rotationAngle = rotationGestureRecognizer.rotation - _previousRotationAngle;
        self.transform = CGAffineTransformRotate(self.transform, rotationAngle);
        _previousRotationAngle = rotationGestureRecognizer.rotation;
    } else if (rotationGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if ([self isInvaildPosition]) {
            [self resetTransform];
        }
        _previousRotationAngle = 0.0f;
    }
}

- (void)handlePinch:(UIPinchGestureRecognizer *)pinchGestureRecognizer
{
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat pinchScale = pinchGestureRecognizer.scale - _previousPinchScale + 1.0f;
        if ((pinchGestureRecognizer.scale <= _maximumScale) || (_maximumScale == 0.0f)) {
            self.transform = CGAffineTransformScale(self.transform, pinchScale, pinchScale);
        }
        _previousPinchScale = pinchGestureRecognizer.scale;
    } else if (pinchGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if ([self isInvaildPosition]) {
            [self resetTransform];
        }
        _previousPinchScale = 1.0f;
    }
}

- (void)handleMove:(UIPanGestureRecognizer *)panGestureRecognizer
{
    if (panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint panTranslation = [panGestureRecognizer translationInView:self];
        
        CGFloat offsetX = panTranslation.x - _previousPanTranslation.x;
        CGFloat offsetY = panTranslation.y - _previousPanTranslation.y;
        
        self.transform = CGAffineTransformTranslate(self.transform, offsetX, offsetY);
        
        _previousPanTranslation = panTranslation;
    } else if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if ([self isInvaildPosition]) {
            [self resetTransform];
        }
        _previousPanTranslation = CGPointMake(0, 0);
    }
}

- (void)resetTransform
{
    _leftTopPoint = self.bounds.origin;
    _rightBottomPoint = CGPointMake(_originSize.width, _originSize.height);
    [UIView animateWithDuration:.35f animations:^{
        self.transform = CGAffineTransformIdentity;
    }];
}

- (BOOL)isInvaildPosition
{
#warning must implement determinant expression
    
    CGFloat angle = atan2(self.transform.b, self.transform.a);
    if (angle < 0.0f) {
        angle = angle + M_PI*2;
    }
    CGAffineTransform reverseTransform = CGAffineTransformMake(self.transform.a * cos(angle) + self.transform.b * sin(angle),
                                                               self.transform.b * cos(angle) - self.transform.a * sin(angle),
                                                               self.transform.c * cos(angle) + self.transform.d * sin(angle),
                                                               self.transform.d * cos(angle) - self.transform.c * sin(angle),
                                                               self.transform.tx,
                                                               self.transform.ty);
    
    CGFloat scaleX = sqrt(pow(reverseTransform.a, 2) + pow(reverseTransform.c, 2));
    CGFloat scaleY = sqrt(pow(reverseTransform.b, 2) + pow(reverseTransform.d, 2));
    
    _resultRotationAngle = angle;
    _resultPinchScale = MAX(scaleX, scaleY);
    _resultPanTraslation = CGPointMake(reverseTransform.tx, reverseTransform.ty);
    
    CGPoint lt = [self leftTopPoint];
    CGPoint rb = [self rightBottomPoint];
    NSLog(@"lt: %@", NSStringFromCGPoint(lt));
    if (lt.x < 0.0f || lt.y < 0.0f || rb.x > _originSize.width || rb.y > _originSize.height) {
        return YES;
    }
    return NO;
}

- (CGPoint)leftTopPoint
{
    CGPoint reverseScalePoint = CGPointMake(_leftTopPoint.x + (_originSize.width - _originSize.width / _resultPinchScale) / 2,
                                            _leftTopPoint.y + (_originSize.height - _originSize.height / _resultPinchScale) / 2);
    
    NSLog(@"sin(%lf): %lf", _resultRotationAngle*180.0f/M_PI, sin(_resultRotationAngle));
    CGPoint reverseTranslationPoint = CGPointMake(reverseScalePoint.x - _resultPanTraslation.x, reverseScalePoint.y - _resultPanTraslation.y);
    CGPoint reverseRotationPoint = CGPointMake(reverseTranslationPoint.x * cos(_resultRotationAngle) + reverseTranslationPoint.y * sin(_resultRotationAngle),
                                               reverseTranslationPoint.y * cos(_resultRotationAngle) - reverseTranslationPoint.x * sin(_resultRotationAngle));
    _leftTopPoint = reverseRotationPoint;
    return reverseRotationPoint;
}

- (CGPoint)rightBottomPoint
{
    CGPoint reverseScalePoint = CGPointMake(_rightBottomPoint.x - (_originSize.width - _originSize.width / _resultPinchScale) / 2,
                                            _rightBottomPoint.y - (_originSize.height - _originSize.height / _resultPinchScale) / 2);
    CGPoint reverseTranslationPoint = CGPointMake(reverseScalePoint.x - _resultPanTraslation.x, reverseScalePoint.y - _resultPanTraslation.y);
    CGPoint reverseRotationPoint = CGPointMake(reverseTranslationPoint.x * cos(_resultRotationAngle) - reverseTranslationPoint.y * sin(_resultRotationAngle),
                                               reverseTranslationPoint.y * cos(_resultRotationAngle) + reverseTranslationPoint.x * sin(_resultRotationAngle));
    _rightBottomPoint = reverseRotationPoint;
    return reverseRotationPoint;
}

#warning TODO: rotation의 기준점 잡기

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

@end
