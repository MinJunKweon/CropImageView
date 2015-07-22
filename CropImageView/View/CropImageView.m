//
//  CropImageView.m
//  CropImageView
//
//  Created by 1000732 on 2015. 7. 22..
//  Copyright (c) 2015년 1000732. All rights reserved.
//

#import "CropImageView.h"

@interface CropImageView ()

@property (nonatomic) CGRect origin;

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
    self = [super initWithImage:image];
    if (self) {
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
    _origin = self.frame;
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
        self.transform = CGAffineTransformScale(self.transform, pinchScale, pinchScale);
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
    [UIView animateWithDuration:.35f animations:^{
        self.transform = CGAffineTransformIdentity;
    }];
}

- (BOOL)isInvaildPosition
{
#warning must implement determinant expression
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

@end
