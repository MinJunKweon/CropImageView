//
//  ImageEditorView.m
//  CropImageView
//
//  Created by 1000732 on 2015. 7. 27..
//  Copyright (c) 2015년 1000732. All rights reserved.
//

#import "ImageEditorView.h"

typedef struct {
    CGPoint tl,tr,bl,br;
} Rectangle;

@interface ImageEditorView () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGestureRecognizer;
@property (nonatomic, strong) UIRotationGestureRecognizer *rotationGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;

@property (nonatomic) NSInteger gestureCount;
@property (nonatomic) CGFloat scale;
@property (nonatomic) CGFloat angle;

@property (nonatomic) CGPoint touchesCenter;

@property (nonatomic) CGPoint scaleCenter;
@property (nonatomic) CGPoint rotationCenter;

@property (nonatomic) CGRect cropRect;
@property (nonatomic) CGSize cropSize;
@property (nonatomic) CGRect initialImageFrame;

@property (nonatomic) CGAffineTransform validTransform;

@end

@implementation ImageEditorView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    self.layer.masksToBounds = YES;
    self.multipleTouchEnabled = YES;
    
    _imageView = [[UIImageView alloc] init];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.userInteractionEnabled = YES;
    [self insertSubview:_imageView belowSubview:self];
    
    _gestureCount = 0;
    _scale = 1.0f;
    
    self.panEnabled = YES;
    self.rotateEnabled = YES;
    self.scaleEnabled = YES;
    self.tapToResetEnabled = YES;
    
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanning:)];
    _panGestureRecognizer.cancelsTouchesInView = NO;
    _panGestureRecognizer.delegate = self;
    [self addGestureRecognizer:_panGestureRecognizer];
    
    _pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    _pinchGestureRecognizer.cancelsTouchesInView = NO;
    _pinchGestureRecognizer.delegate = self;
    [self addGestureRecognizer:_pinchGestureRecognizer];
    
    _rotationGestureRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotation:)];
    _rotationGestureRecognizer.cancelsTouchesInView = NO;
    _rotationGestureRecognizer.delegate = self;
    [self addGestureRecognizer:_rotationGestureRecognizer];
    
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    _tapGestureRecognizer.numberOfTapsRequired = 2;
    _tapGestureRecognizer.delegate = self;
    [self addGestureRecognizer:_tapGestureRecognizer];
}

#pragma mark - Global Animated

-(void)reset:(BOOL)animated
{
    CGFloat width = 0.0f;
    CGFloat height = 0.0f;
    CGFloat sourceAspect = _image.size.height / _image.size.width;
    CGFloat cropAspect = self.cropRect.size.height / self.cropRect.size.width;
    
    if(sourceAspect > cropAspect) {
        width = CGRectGetWidth(_cropRect);
        height = sourceAspect * width;
    } else {
        height = CGRectGetHeight(_cropRect);
        width = height / sourceAspect;
    }
    
    _scale = 1;
    
    _initialImageFrame = CGRectMake(CGRectGetMidX(_cropRect) - width / 2,
                                    CGRectGetMidY(_cropRect) - height / 2,
                                    width, height);
    self.validTransform = CGAffineTransformMakeScale(_scale, _scale);
    
    void (^doReset)(void) = ^{
        _imageView.transform = CGAffineTransformIdentity;
        _imageView.frame = _initialImageFrame;
        _imageView.transform = self.validTransform;
    };
    if(animated) {
        self.userInteractionEnabled = NO;
        [UIView animateWithDuration:.35f animations:doReset completion:^(BOOL finished) {
            self.userInteractionEnabled = YES;
        }];
    } else {
        doReset();
    }
}

- (void)crop
{
    if ([_delegate respondsToSelector:@selector(imageEditorViewDidCropped:translate:scale:angle:)]) {
        [_delegate imageEditorViewDidCropped:self translate:[self translateWithTransform:self.validTransform]
                                                      scale:[self scaleWithTransform:self.validTransform]
                                                      angle:[self rotationAngleWithTransform:self.validTransform]];
    }
}

#pragma mark - Touches Handler

- (void)touchesHandler:(NSSet *)events  // 터치된 위치의 중앙값 계산
{
    _touchesCenter = CGPointZero;
    if (events.count < 2) {
        return;
    }
    
    [events enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        UITouch *touch = (UITouch *)obj;
        CGPoint touchLocation = [touch locationInView:_imageView];
        _touchesCenter = CGPointMake(self.touchesCenter.x + touchLocation.x, self.touchesCenter.y +touchLocation.y);
    }];
    _touchesCenter = CGPointMake(self.touchesCenter.x / events.count, self.touchesCenter.y / events.count);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesHandler:[event allTouches]];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesHandler:[event allTouches]];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesHandler:[event allTouches]];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesHandler:[event allTouches]];
}

#pragma mark - Gesture Handler

- (void)handlePanning:(UIPanGestureRecognizer *)panGestureRecognizer
{
    if ([self canHandleGesture:panGestureRecognizer.state]) {
        CGPoint translation = [panGestureRecognizer translationInView:_imageView];
        CGAffineTransform transform = CGAffineTransformTranslate(_imageView.transform, translation.x, translation.y);
        self.imageView.transform = transform;
        [self checkBoundsWithTransform:transform];
        
        [panGestureRecognizer setTranslation:CGPointMake(0, 0) inView:_imageView];
    }
}

- (void)handlePinch:(UIPinchGestureRecognizer *)pinchGestureRecognizer
{
    if ([self canHandleGesture:pinchGestureRecognizer.state]) {
        if (pinchGestureRecognizer.state == UIGestureRecognizerStateBegan) {
            _scaleCenter = _touchesCenter;
        }
        if (_scale > _maximumScale && _maximumScale) {
            return;
        }
        CGFloat offsetX = _scaleCenter.x - _imageView.bounds.size.width/2;
        CGFloat offsetY = _scaleCenter.y - _imageView.bounds.size.height/2;
        
        CGAffineTransform transform = CGAffineTransformTranslate(_imageView.transform, offsetX, offsetY);
        transform = CGAffineTransformScale(transform, pinchGestureRecognizer.scale, pinchGestureRecognizer.scale);
        _imageView.transform = CGAffineTransformTranslate(transform, -offsetX, -offsetY);
        
        _scale *= pinchGestureRecognizer.scale;
        
        pinchGestureRecognizer.scale = 1.0f;
        
        [self checkBoundsWithTransform:transform];
    }
}


- (void)handleRotation:(UIRotationGestureRecognizer *)rotationGestureRecognizer
{
    if ([self canHandleGesture:rotationGestureRecognizer.state]) {
        if(rotationGestureRecognizer.state == UIGestureRecognizerStateBegan){
            _rotationCenter = _touchesCenter;
        }
        CGFloat offsetX = _rotationCenter.x - _imageView.bounds.size.width/2;
        CGFloat offsetY = _rotationCenter.y - _imageView.bounds.size.height/2;
        
        CGAffineTransform transform =  CGAffineTransformTranslate(_imageView.transform, offsetX, offsetY);
        transform = CGAffineTransformRotate(transform, rotationGestureRecognizer.rotation);
        transform = CGAffineTransformTranslate(transform, -offsetX, -offsetY);
        _imageView.transform = transform;
        
        [self checkBoundsWithTransform:transform];
        
        rotationGestureRecognizer.rotation = 0;
    }
}

- (void)handleTap:(UITapGestureRecognizer *)tapGestureRecognizer
{
    [self reset:YES];
}

- (BOOL)canHandleGesture:(UIGestureRecognizerState)state
{
    BOOL handle = YES;
    switch (state) {
        case UIGestureRecognizerStateBegan:
            self.gestureCount++;
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
            self.gestureCount--;
            handle = NO;
            if(self.gestureCount == 0) {
                CGFloat scale = [self boundedScale:self.scale];
                if(scale != self.scale) {
                    CGFloat deltaX = self.scaleCenter.x-self.imageView.bounds.size.width/2.0;
                    CGFloat deltaY = self.scaleCenter.y-self.imageView.bounds.size.height/2.0;
                    
                    CGAffineTransform transform =  CGAffineTransformTranslate(self.imageView.transform, deltaX, deltaY);
                    transform = CGAffineTransformScale(transform, scale/self.scale , scale/self.scale);
                    transform = CGAffineTransformTranslate(transform, -deltaX, -deltaY);
                    [self checkBoundsWithTransform:transform];
                    self.userInteractionEnabled = NO;
                    [UIView animateWithDuration:.2f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                        self.imageView.transform = self.validTransform;
                    } completion:^(BOOL finished) {
                        self.userInteractionEnabled = YES;
                        self.scale = scale;
                    }];
                } else {
                    self.userInteractionEnabled = NO;
                    [self checkBoundsWithTransform:self.imageView.transform];
                    [UIView animateWithDuration:.2f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                        self.imageView.transform = self.validTransform;
                    } completion:^(BOOL finished) {
                        self.userInteractionEnabled = YES;
                        self.scale = scale;
                    }];
                }
            }
            break;
        default:
            break;
    }
    return handle;
}

- (CGFloat)boundedScale:(CGFloat)scale;
{
    CGFloat boundedScale = scale;
    if(scale < 1.0f) {
        boundedScale = 1.0f;
    } else if(_maximumScale > 1 && scale > _maximumScale) {
        boundedScale = _maximumScale;
    }
    return boundedScale;
}

- (void)checkBoundsWithTransform:(CGAffineTransform)transform
{
    CGRect r1 = [self boundingBoxForRect:self.cropRect rotatedByRadians:[self rotationAngleWithTransform:_imageView.transform]];
    Rectangle r2 = [self applyTransform:transform toRect:self.initialImageFrame];
    
    CGAffineTransform t = CGAffineTransformMakeTranslation(CGRectGetMidX(self.cropRect), CGRectGetMidY(self.cropRect));
    t = CGAffineTransformRotate(t, -[self rotationAngleWithTransform:_imageView.transform]);
    t = CGAffineTransformTranslate(t, -CGRectGetMidX(self.cropRect), -CGRectGetMidY(self.cropRect));
    
    Rectangle r3 = [self applyTransform:t toRectangle:r2];
    
    if(CGRectContainsRect([self CGRectFromRectangle:r3], r1)) {
        self.validTransform = transform;
    }
}

#pragma mark - Gesture Recognizer Delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark - Setter

- (void)setPanEnabled:(BOOL)panEnabled
{
    _panEnabled = panEnabled;
    _panGestureRecognizer.enabled = panEnabled;
}

- (void)setRotateEnabled:(BOOL)rotateEnabled
{
    _rotateEnabled = rotateEnabled;
    _rotationGestureRecognizer.enabled = rotateEnabled;
}

- (void)setScaleEnabled:(BOOL)scaleEnabled
{
    _scaleEnabled = scaleEnabled;
    _pinchGestureRecognizer.enabled = scaleEnabled;
}

- (void)setTapToResetEnabled:(BOOL)tapToResetEnabled
{
    _tapToResetEnabled = tapToResetEnabled;
    _tapGestureRecognizer.enabled = tapToResetEnabled;
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    _imageView.image = image;
}

- (void)setCropSize:(CGSize)cropSize
{
    _cropRect = CGRectMake((self.bounds.size.width - cropSize.width) / 2,
                           (self.bounds.size.height - cropSize.height) / 2,
                           cropSize.width,
                           cropSize.height);
}

- (CGSize)cropSize
{
    return self.cropRect.size;
}

- (CGRect)cropRect
{
    if(self.bounds.size.width == 0 || self.bounds.size.height == 0) {
        _cropRect = CGRectMake((self.imageView.frame.size.width - self.bounds.size.width) / 2,
                               (self.imageView.frame.size.height - self.bounds.size.height) / 2,
                               self.bounds.size.width,
                               self.bounds.size.height);
    }
    return _cropRect;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    _cropRect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    _imageView.frame = self.frame;
    _initialImageFrame = self.frame;
    [self reset:NO];
}


#pragma mark - Transform

- (CGFloat)rotationAngleWithTransform:(CGAffineTransform)transform
{
    return atan2(transform.b, transform.a);
}

- (CGPoint)translateWithTransform:(CGAffineTransform)transform
{
    return CGPointMake(transform.tx, transform.ty);
}

- (CGFloat)scaleWithTransform:(CGAffineTransform)transform
{
    CGFloat scaleX = sqrt(pow(transform.a, 2) + pow(transform.c, 2));
    CGFloat scaleY = sqrt(pow(transform.b, 2) + pow(transform.d, 2));
    
    return MAX(scaleX, scaleY);
}

- (CGRect)boundingBoxForRect:(CGRect)rect rotatedByRadians:(CGFloat)angle
{
    CGAffineTransform t = CGAffineTransformMakeTranslation(CGRectGetMidX(rect), CGRectGetMidY(rect));
    t = CGAffineTransformRotate(t, angle);
    t = CGAffineTransformTranslate(t, -CGRectGetMidX(rect), -CGRectGetMidY(rect));
    return CGRectApplyAffineTransform(rect, t);
}

#pragma mark - Rectangle

- (Rectangle)RectangleFromCGRect:(CGRect)rect
{
    return (Rectangle) {
        .tl = (CGPoint){rect.origin.x, rect.origin.y},
        .tr = (CGPoint){CGRectGetMaxX(rect), rect.origin.y},
        .br = (CGPoint){CGRectGetMaxX(rect), CGRectGetMaxY(rect)},
        .bl = (CGPoint){rect.origin.x, CGRectGetMaxY(rect)}
    };
}

- (CGRect)CGRectFromRectangle:(Rectangle)rectangle
{
    return (CGRect) {
        .origin = rectangle.tl,
        .size = (CGSize) {
            .width = rectangle.tr.x - rectangle.tl.x,
            .height = rectangle.bl.y - rectangle.tl.y
        }
    };
}

- (Rectangle)applyTransform:(CGAffineTransform)transform toRect:(CGRect)rect
{
    CGAffineTransform t = CGAffineTransformMakeTranslation(CGRectGetMidX(rect), CGRectGetMidY(rect));
    t = CGAffineTransformConcat(self.imageView.transform, t);
    t = CGAffineTransformTranslate(t,-CGRectGetMidX(rect), -CGRectGetMidY(rect));
    
    Rectangle rectangle = [self RectangleFromCGRect:rect];
    return (Rectangle) {
        .tl = CGPointApplyAffineTransform(rectangle.tl, t),
        .tr = CGPointApplyAffineTransform(rectangle.tr, t),
        .br = CGPointApplyAffineTransform(rectangle.br, t),
        .bl = CGPointApplyAffineTransform(rectangle.bl, t)
    };
}

- (Rectangle)applyTransform:(CGAffineTransform)transform toRectangle:(Rectangle)rectangle
{
    return (Rectangle) {
        .tl = CGPointApplyAffineTransform(rectangle.tl, transform),
        .tr = CGPointApplyAffineTransform(rectangle.tr, transform),
        .br = CGPointApplyAffineTransform(rectangle.br, transform),
        .bl = CGPointApplyAffineTransform(rectangle.bl, transform)
    };
}
@end
