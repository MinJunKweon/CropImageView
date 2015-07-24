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

@property (nonatomic) CGFloat xMargin;
@property (nonatomic) CGFloat yMargin;

@property (nonatomic) CGPoint contentLeftTop;
@property (nonatomic) CGSize originSize;

@property (nonatomic) CGFloat imageRotationAngle;
@property (nonatomic) CGFloat imageScale;
@property (nonatomic) CGPoint imageTranslation;

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
        _imageRotationAngle = 0.0f;
        _imageScale = 1.0f;
        _imageTranslation = CGPointZero;
        
//        _previousRotationAngle = 0.0f;
//        _previousPinchScale = 1.0f;
//        _previousPanTranslation = CGPointMake(0, 0);
        
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
    
    CGRect imageRect = [self imagePosition];
    _xMargin = fabs(imageRect.origin.x);
    _yMargin = fabs(imageRect.origin.y);
    _originSize = imageRect.size;
}

- (void)saveTransform
{
    
}

#pragma mark - Gesture Recognizer

- (void)handleRotate:(UIRotationGestureRecognizer *)rotationGestureRecognizer
{
    if (rotationGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        self.transform = CGAffineTransformRotate(self.transform, rotationGestureRecognizer.rotation);
        _imageRotationAngle += rotationGestureRecognizer.rotation;
        rotationGestureRecognizer.rotation = 0.0f;
        [self saveTransform];
    } else if (rotationGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        
    }
}

- (void)handlePinch:(UIPinchGestureRecognizer *)pinchGestureRecognizer
{
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        if ((_imageScale <= _maximumScale) || (_maximumScale == 0.0f)) {
            self.transform = CGAffineTransformScale(self.transform, pinchGestureRecognizer.scale, pinchGestureRecognizer.scale);
            _imageScale += pinchGestureRecognizer.scale - 1.0f;
            pinchGestureRecognizer.scale = 1.0f;
            [self saveTransform];
        }
    } else if (pinchGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if ([self isInvaildPosition]) {
            [self resetTransform];
        }
    }
}

- (void)handleMove:(UIPanGestureRecognizer *)panGestureRecognizer
{
    if (panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint panTranslation = [panGestureRecognizer translationInView:self];
        self.transform = CGAffineTransformTranslate(self.transform, panTranslation.x, panTranslation.y);
        _imageTranslation.x += panTranslation.x * _imageScale;
        _imageTranslation.y += panTranslation.y * _imageScale;
        [panGestureRecognizer setTranslation:CGPointZero inView:self];
        [self saveTransform];
    } else if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if ([self isInvaildPosition]) {
            [self resetTransform];
        }
    }
}

- (void)resetTransform
{
    _imageRotationAngle = 0.0f;
    _imageScale = 1.0f;
    _imageTranslation = CGPointZero;
    [UIView animateWithDuration:.35f animations:^{
        self.transform = CGAffineTransformMakeRotation(_imageRotationAngle);
        self.transform = CGAffineTransformMakeScale(_imageScale, _imageScale);
        self.transform = CGAffineTransformMakeTranslation(_imageTranslation.x, _imageTranslation.y);
    }];
}

- (BOOL)predictInvaildPositionWithScale:(CGFloat)scale angle:(CGFloat)angle offset:(CGPoint)offset
{
    BOOL isInvaild = YES;
    
    CGFloat predictScale = _imageScale + scale - 1.0f;
    CGFloat predictAngle = _imageRotationAngle + angle;
    CGPoint predictOffset = CGPointMake(_imageTranslation.x + offset.x, _imageTranslation.y + offset.y);
    
    CGPoint ltPoint = [self edgePointWithType:kEdgePointTypeLeftTop
                                        scale:predictScale angle:predictAngle offset:predictOffset];
    CGPoint lbPoint = [self edgePointWithType:kEdgePointTypeLeftBottom
                                        scale:predictScale angle:predictAngle offset:predictOffset];
    CGPoint rtPoint = [self edgePointWithType:kEdgePointTypeRightTop
                                        scale:predictScale angle:predictAngle offset:predictOffset];
    CGPoint rbPoint = [self edgePointWithType:kEdgePointTypeRightBottom
                                        scale:predictScale angle:predictAngle offset:predictOffset];;
    
    if ([self isInImage:ltPoint]) {
        if ([self isInImage:lbPoint]) {
            if ([self isInImage:rtPoint]) {
                if ([self isInImage:rbPoint]) {
                    isInvaild = NO;
                }
            }
        }
    }
    
    return isInvaild;
}

- (BOOL)isInvaildPosition
{
    CGPoint ltPoint = [self edgePointWithType:kEdgePointTypeLeftTop
                                        scale:_imageScale angle:_imageRotationAngle offset:_imageTranslation];
    CGPoint lbPoint = [self edgePointWithType:kEdgePointTypeLeftBottom
                                        scale:_imageScale angle:_imageRotationAngle offset:_imageTranslation];
    CGPoint rtPoint = [self edgePointWithType:kEdgePointTypeRightTop
                                        scale:_imageScale angle:_imageRotationAngle offset:_imageTranslation];
    CGPoint rbPoint = [self edgePointWithType:kEdgePointTypeRightBottom
                                        scale:_imageScale angle:_imageRotationAngle offset:_imageTranslation];;
    
    NSLog(@"angle: %lf\nrect: %@\nlt: %@\t\trt: %@\nlb: %@\t\trb: %@", _imageRotationAngle*180/M_PI, NSStringFromCGRect(self.frame),
          NSStringFromCGPoint(ltPoint),
          NSStringFromCGPoint(rtPoint),
          NSStringFromCGPoint(lbPoint),
          NSStringFromCGPoint(rbPoint));
    
    _imageEdgePoint = [self imageEdgePointsWithScale:_imageScale];
    
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

- (CGFloat)rotationAngleWithTransform:(CGAffineTransform)transform
{
    return atan2(transform.b, transform.a);
}

- (CGFloat)scaleWithTransform:(CGAffineTransform)transform
{
    CGFloat scaleX = sqrt(pow(transform.a, 2) + pow(transform.c, 2));
    CGFloat scaleY = sqrt(pow(transform.b, 2) + pow(transform.d, 2));
    
    return MAX(scaleX, scaleY);
}

- (CGPoint)translationWithTransform:(CGAffineTransform)transform
{
    return CGPointMake(transform.tx, transform.ty);
}

- (CGAffineTransform)reverseRotationWithTransform:(CGAffineTransform)transform angle:(CGFloat)angle
{
    CGAffineTransform reverseTransform = CGAffineTransformMake(transform.a * cos(angle) + transform.b * sin(angle),
                                                               transform.b * cos(angle) - transform.a * sin(angle),
                                                               transform.c * cos(angle) + transform.d * sin(angle),
                                                               transform.d * cos(angle) - transform.c * sin(angle),
                                                               transform.tx,
                                                               transform.ty);
    return reverseTransform;
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
            point.x < ((subIndexPoint.x - indexPoint.x) * (point.y - indexPoint.y) / (subIndexPoint.y - indexPoint.y) + indexPoint.x)) {
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
            return CGPointMake((width * scale / 2.0f) - (radius * cos(beta - angle)) + _xMargin - offset.x,
                               (height * scale / 2.0f) - (radius * sin(beta - angle)) + _yMargin - offset.y);
            
        case kEdgePointTypeLeftBottom:
            return CGPointMake((width * scale / 2.0f) - (radius * sin(beta - angle)) + _xMargin - offset.x,
                               (height * scale / 2.0f) + (radius * cos(beta - angle)) + _yMargin - offset.y);
            
        case kEdgePointTypeRightTop:
            return CGPointMake((width * scale / 2.0f) + (radius * sin(beta - angle)) + _xMargin - offset.x,
                               (height * scale / 2.0f) - (radius * cos(beta - angle)) + _yMargin - offset.y);
            
        case kEdgePointTypeRightBottom:
            return CGPointMake((width * scale / 2.0f) + (radius * cos(beta - angle)) + _xMargin - offset.x,
                               (height * scale / 2.0f) + (radius * sin(beta - angle)) + _yMargin - offset.y);
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
    [edgePointArray addObject:[NSValue valueWithCGPoint:CGPointMake(0, 0)]];
    
    return edgePointArray;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (CGRect)imagePosition
{
    float x = 0.0f;
    float y = 0.0f;
    float w = 0.0f;
    float h = 0.0f;
    CGFloat ratio = 0.0f;
    CGFloat horizontalRatio = self.frame.size.width / self.image.size.width;
    CGFloat verticalRatio = self.frame.size.height / self.image.size.height;
    
    switch (self.contentMode) {
        case UIViewContentModeScaleToFill:
            w = self.frame.size.width;
            h = self.frame.size.height;
            break;
        case UIViewContentModeScaleAspectFit:
            // contents scaled to fit with fixed aspect. remainder is transparent
            ratio = MIN(horizontalRatio, verticalRatio);
            w = self.image.size.width*ratio;
            h = self.image.size.height*ratio;
            x = (horizontalRatio == ratio ? 0 : ((self.frame.size.width - w)/2));
            y = (verticalRatio == ratio ? 0 : ((self.frame.size.height - h)/2));
            break;
        case UIViewContentModeScaleAspectFill:
            // contents scaled to fill with fixed aspect. some portion of content may be clipped.
            ratio = MAX(horizontalRatio, verticalRatio);
            w = self.image.size.width*ratio;
            h = self.image.size.height*ratio;
            x = (horizontalRatio == ratio ? 0 : ((self.frame.size.width - w)/2));
            y = (verticalRatio == ratio ? 0 : ((self.frame.size.height - h)/2));
            break;
        case UIViewContentModeCenter:
            // contents remain same size. positioned adjusted.
            w = self.image.size.width;
            h = self.image.size.height;
            x = (self.frame.size.width - w)/2;
            y = (self.frame.size.height - h)/2;
            break;
        case UIViewContentModeTop:
            w = self.image.size.width;
            h = self.image.size.height;
            x = (self.frame.size.width - w)/2;
            break;
        case UIViewContentModeBottom:
            w = self.image.size.width;
            h = self.image.size.height;
            y = (self.frame.size.height - h);
            x = (self.frame.size.width - w)/2;
            break;
        case UIViewContentModeLeft:
            w = self.image.size.width;
            h = self.image.size.height;
            y = (self.frame.size.height - h)/2;
            break;
        case UIViewContentModeRight:
            w = self.image.size.width;
            h = self.image.size.height;
            y = (self.frame.size.height - h)/2;
            x = (self.frame.size.width - w);
            break;
        case UIViewContentModeTopLeft:
            w = self.image.size.width;
            h = self.image.size.height;
            break;
        case UIViewContentModeTopRight:
            w = self.image.size.width;
            h = self.image.size.height;
            x = (self.frame.size.width - w);
            break;
        case UIViewContentModeBottomLeft:
            w = self.image.size.width;
            h = self.image.size.height;
            y = (self.frame.size.height - h);
            break;
        case UIViewContentModeBottomRight:
            w = self.image.size.width;
            h = self.image.size.height;
            y = (self.frame.size.height - h);
            x = (self.frame.size.width - w);
        default:
            break;
    }
    return CGRectMake(x, y, w, h);
}

@end
