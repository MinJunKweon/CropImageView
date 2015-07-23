//
//  CropImageView.m
//  CropImageView
//
//  Created by 1000732 on 2015. 7. 22..
//  Copyright (c) 2015년 1000732. All rights reserved.
//

#import "CropImageView.h"

typedef NS_ENUM(NSInteger, kViewType) {
    kViewTypeImage,
    kViewTypeCropView
};

typedef NS_ENUM(NSInteger, kEdgePointType){
    kEdgePointTypeLeftTop,
    kEdgePointTypeLeftBottom,
    kEdgePointTypeRightTop,
    kEdgePointTypeRightBottom
};

@interface CropImageView ()

@property (nonatomic) CGSize originSize;

@property (nonatomic) CGFloat previousRotationAngle;
@property (nonatomic) CGFloat previousPinchScale;
@property (nonatomic) CGPoint previousPanTranslation;

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
        if ((pinchScale <= _maximumScale) || (_maximumScale == 0.0f)) {
            self.transform = CGAffineTransformScale(self.transform, pinchScale, pinchScale);
            _previousPinchScale = pinchGestureRecognizer.scale;
        }
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
    [UIView animateWithDuration:.35f animations:^{
        self.transform = CGAffineTransformIdentity;
    }];
}

- (BOOL)isInvaildPosition
{
    CGFloat scale;
    CGPoint offset;
    CGFloat angle = atan2(self.transform.b, self.transform.a);
    
    CGAffineTransform reverseTransform = CGAffineTransformMake(self.transform.a * cos(angle) + self.transform.b * sin(angle),
                                                               self.transform.b * cos(angle) - self.transform.a * sin(angle),
                                                               self.transform.c * cos(angle) + self.transform.d * sin(angle),
                                                               self.transform.d * cos(angle) - self.transform.c * sin(angle),
                                                               self.transform.tx,
                                                               self.transform.ty);

    CGFloat scaleX = sqrt(pow(reverseTransform.a, 2) + pow(reverseTransform.c, 2));
    CGFloat scaleY = sqrt(pow(reverseTransform.b, 2) + pow(reverseTransform.d, 2));
    
    scale = MAX(scaleX, scaleY);
    offset = CGPointMake(reverseTransform.tx, reverseTransform.ty);

    CGPoint ltPoint = [self edgePointWithType:kEdgePointTypeLeftTop
                                     viewType:kViewTypeCropView
                                        scale:scale angle:angle offset:offset];
    CGPoint lbPoint = [self edgePointWithType:kEdgePointTypeLeftBottom
                                     viewType:kViewTypeCropView
                                        scale:scale angle:angle offset:offset];
    CGPoint rtPoint = [self edgePointWithType:kEdgePointTypeRightTop
                                     viewType:kViewTypeCropView
                                        scale:scale angle:angle offset:offset];
    CGPoint rbPoint = [self edgePointWithType:kEdgePointTypeRightBottom
                                     viewType:kViewTypeCropView
                                        scale:scale angle:angle offset:offset];
    
    CGFloat scaleWidth = _originSize.width * scale;
    CGFloat scaleHeight = _originSize.height * scale;
    
    if (0.0f <= ltPoint.x && scaleWidth >= ltPoint.x && 0.0f <= ltPoint.y && scaleHeight >= ltPoint.y) {
        if (0.0f <= lbPoint.x && scaleWidth >= lbPoint.x && 0.0f <= lbPoint.y && scaleHeight >= lbPoint.y) {
            if (0.0f <= rtPoint.x && scaleWidth >= rtPoint.x && 0.0f <= rtPoint.y && scaleHeight >= rtPoint.y) {
                if (0.0f <= rbPoint.x && scaleWidth >= rbPoint.x && 0.0f <= rbPoint.y && scaleHeight >= rbPoint.y) {
                    return NO;
                }
            }
        }
    }
    
    return YES;
}

- (CGPoint)edgePointWithType:(kEdgePointType)type viewType:(kViewType)viewType scale:(CGFloat)scale angle:(CGFloat)angle offset:(CGPoint)offset
{
    
    CGFloat width = _originSize.width;
    CGFloat height = _originSize.height;
    
    CGFloat radius = sqrt(pow(width/2.0f, 2) + pow(height/2.0f, 2));
    CGFloat beta = atan(height/width);
    
    if (viewType == kViewTypeImage) {
        radius = radius * scale;
    }
    
    switch (type) {
        case kEdgePointTypeLeftTop:
            return CGPointMake((width * scale / 2.0f) - (radius * cos(beta - angle)) + offset.x,
                               (height * scale / 2.0f) - (radius * sin(beta - angle)) + offset.y);
            
        case kEdgePointTypeLeftBottom:
            return CGPointMake((width * scale / 2.0f) - (radius * cos(beta - angle)) + offset.x,
                               (height * scale / 2.0f) + (radius * sin(beta - angle)) + offset.y);
            
        case kEdgePointTypeRightTop:
            return CGPointMake((width * scale / 2.0f) + (radius * cos(beta - angle)) + offset.x,
                               (height * scale / 2.0f) - (radius * sin(beta - angle)) + offset.y);
            
        case kEdgePointTypeRightBottom:
            return CGPointMake((width * scale / 2.0f) + (radius * cos(beta - angle)) + offset.x,
                               (height * scale / 2.0f) + (radius * sin(beta - angle)) + offset.y);
        default:
            return CGPointZero;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

@end
