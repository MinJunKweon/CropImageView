//
//  CropImageView.m
//  CropImageView
//
//  Created by 1000732 on 2015. 7. 22..
//  Copyright (c) 2015년 1000732. All rights reserved.
//

#import "CropImageView.h"

typedef NS_ENUM(NSInteger, kEdgePointType){
    kEdgePointTypeLeftTop = 0,
    kEdgePointTypeLeftBottom,
    kEdgePointTypeRightBottom,
    kEdgePointTypeRightTop
};

@interface CropImageView ()

@property (nonatomic) CGSize originSize;

@property (nonatomic) CGFloat previousRotationAngle;
@property (nonatomic) CGFloat previousPinchScale;
@property (nonatomic) CGPoint previousPanTranslation;

@property (nonatomic) NSMutableArray *imageEdgePoint;

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
                                 scale:scale angle:angle offset:offset];
    CGPoint lbPoint = [self edgePointWithType:kEdgePointTypeLeftBottom
                                 scale:scale angle:angle offset:offset];
    CGPoint rtPoint = [self edgePointWithType:kEdgePointTypeRightTop
                                 scale:scale angle:angle offset:offset];
    CGPoint rbPoint = [self edgePointWithType:kEdgePointTypeRightBottom
                                 scale:scale angle:angle offset:offset];
    
//    NSLog(@"\nrect: %@\nlt: %@\t\trt: %@\nlb: %@\t\trb: %@", NSStringFromCGRect(self.frame),
//          NSStringFromCGPoint([self edgePointWithType:kEdgePointTypeLeftTop scale:scale angle:angle offset:offset]),
//          NSStringFromCGPoint([self edgePointWithType:kEdgePointTypeRightTop scale:scale angle:angle offset:offset]),
//          NSStringFromCGPoint([self edgePointWithType:kEdgePointTypeLeftBottom scale:scale angle:angle offset:offset]),
//          NSStringFromCGPoint([self edgePointWithType:kEdgePointTypeRightBottom scale:scale angle:angle offset:offset]));
    
    _imageEdgePoint = [self imageEdgePointsWithScale:scale];
    
    if ([self isInImage:ltPoint]) {
        if ([self isInImage:lbPoint]) {
            if ([self isInImage:rtPoint]) {
                if ([self isInImage:rbPoint]) {
                    return NO;
                }
            }
        }
    }
    
    return YES;
}

- (BOOL)isInImage:(CGPoint)point    // point in polygon algorithm
{
    BOOL isInside = false;
    CGPoint firstPoint = [_imageEdgePoint[0] CGPointValue];
    
    CGFloat minX = firstPoint.x, maxX = firstPoint.x;
    CGFloat minY = firstPoint.y, maxY = firstPoint.y;
    
    for (NSInteger i = 1; i < _imageEdgePoint.count; i++) {
        CGPoint indexPoint = [_imageEdgePoint[i] CGPointValue];
        minX = MIN(indexPoint.x, minX);
        maxX = MAX(indexPoint.x, maxX);
        minY = MIN(indexPoint.y, minY);
        maxY = MAX(indexPoint.y, maxY);
    }
    
    if (point.x < minX || point.x > maxX || point.y < minY || point.y > maxY) {
        return false;
    }
    
    for (NSInteger i = 0, j = _imageEdgePoint.count - 1; i < _imageEdgePoint.count; j = i++) {
        CGPoint indexPoint = [_imageEdgePoint[i] CGPointValue];
        CGPoint subIndexPoint = [_imageEdgePoint[j] CGPointValue];
        if ((indexPoint.y > point.y) != (subIndexPoint.y > point.y) &&
            point.x < (subIndexPoint.x - indexPoint.x) * (point.y - indexPoint.y) / (subIndexPoint.y - indexPoint.y) + indexPoint.x) {
            isInside = !isInside;
        }
    }
    
    return isInside;
}

- (CGPoint)edgePointWithType:(kEdgePointType)type scale:(CGFloat)scale angle:(CGFloat)angle offset:(CGPoint)offset
{
    
    CGFloat width = _originSize.width;
    CGFloat height = _originSize.height;
    
    CGFloat radius = sqrt(pow(width/2.0f, 2) + pow(height/2.0f, 2));
    CGFloat beta = atan(height/width);

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
    
    return CGPointZero;
}

- (NSMutableArray *)imageEdgePointsWithScale:(CGFloat)scale
{
    NSMutableArray *edgePointArray =[[NSMutableArray alloc] init];
    [edgePointArray addObject:[NSValue valueWithCGPoint:CGPointMake(0, 0)]];
    [edgePointArray addObject:[NSValue valueWithCGPoint:CGPointMake(_originSize.width*scale, 0)]];
    [edgePointArray addObject:[NSValue valueWithCGPoint:CGPointMake(_originSize.width*scale, _originSize.height*scale)]];
    [edgePointArray addObject:[NSValue valueWithCGPoint:CGPointMake(0, _originSize.height*scale)]];
    
    return edgePointArray;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

@end
