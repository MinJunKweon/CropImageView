//
//  ImageCropView.m
//  CropImageView
//
//  Created by 1000732 on 2015. 8. 3..
//  Copyright (c) 2015년 1000732. All rights reserved.
//

#import "ImageCropView.h"

@interface ImageCropView () <UIScrollViewDelegate>

@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *croppedAreaView;

@property (nonatomic, assign) CGFloat      zoomScale;
@property (nonatomic, assign) CGFloat      maximumZoomScale;
@property (nonatomic, assign) CGFloat      minimumZoomScale;
@property (nonatomic, assign) CGPoint      contentOffset;
@property (nonatomic, assign) UIEdgeInsets contentInset;
@property (nonatomic, assign) CGFloat      minimumCroppedImageSideLength;

@property (nonatomic) CGRect cropRect;
@property (nonatomic) CGRect initialFrame;

@end

@implementation ImageCropView

#pragma mark - Initializer

- (instancetype)init
{
    self = [super init];
    if (self) {
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToReset)];
        
        _scrollView = [[UIScrollView alloc] init];
        _imageView = [[UIImageView alloc] init];
        _croppedAreaView = [[UIView alloc] init];
        
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    _minimumCroppedImageSideLength = MIN(MIN(CGRectGetHeight(self.imageView.bounds), CGRectGetWidth(self.imageView.bounds)), self.minimumCroppedImageSideLength);;
    _scrollView.delegate = self;
    _scrollView.minimumZoomScale = 1.0f;
    _scrollView.maximumZoomScale = 2.0f;
    _scrollView.clipsToBounds = YES;
    
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    _tapGestureRecognizer.numberOfTapsRequired = 2;
    
    [_scrollView addGestureRecognizer:_tapGestureRecognizer];
    [_scrollView addSubview:_imageView];
    [self addSubview:_scrollView];
}

#pragma mark - Setter

- (void)setImage:(UIImage *)image
{
    _image = image;
    _imageView.image = image;
}

#pragma mark - Frame

- (void)drawRect:(CGRect)rect
{
    _scrollView.frame = rect;
    _imageView.frame = rect;
    _initialFrame = rect;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    _scrollView.frame = frame;
    _imageView.frame = frame;
    _initialFrame = frame;
    
    [self resetZoomScaleAndContentOffset];
}

- (void)resetZoomScaleAndContentOffset
{
    CGFloat minZoomScaleX = CGRectGetWidth(self.bounds) / self.image.size.width;
    CGFloat minZoomScaleY = CGRectGetHeight(self.bounds) / self.image.size.height;
    
    CGFloat maxZoomScaleX = CGRectGetWidth(self.bounds) / self.minimumCroppedImageSideLength;
    CGFloat maxZoomScaleY = CGRectGetHeight(self.bounds) / self.minimumCroppedImageSideLength;
    
    self.scrollView.minimumZoomScale = MAX(minZoomScaleX, minZoomScaleY);
    self.scrollView.maximumZoomScale = MIN(maxZoomScaleX, maxZoomScaleY);
    
    [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:NO];
    
    CGPoint contentOffset = CGPointZero;
    contentOffset.x = (self.scrollView.contentSize.width - (CGRectGetWidth(self.scrollView.bounds) - self.scrollView.contentInset.left - self.scrollView.contentInset.right)) / 2.0f;
    contentOffset.y = (self.scrollView.contentSize.height - (CGRectGetHeight(self.scrollView.bounds) - self.scrollView.contentInset.top - self.scrollView.contentInset.bottom)) / 2.0f;
    contentOffset.x -= self.scrollView.contentInset.left;
    contentOffset.y -= self.scrollView.contentInset.top;
    [self.scrollView setContentOffset:contentOffset animated:NO];
    
    [self updateScrollViewParameters];
}

#pragma mark - Helpers

- (void)updateScrollViewParameters
{
    self.zoomScale = self.scrollView.zoomScale;
    self.maximumZoomScale = self.scrollView.maximumZoomScale;
    self.minimumZoomScale = self.scrollView.minimumZoomScale;
    self.contentOffset = self.scrollView.contentOffset;
    self.contentInset = self.scrollView.contentInset;
}

#pragma mark - Scroll View Delegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    [self updateScrollViewParameters];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self updateScrollViewParameters];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self updateScrollViewParameters];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self updateScrollViewParameters];
}


#pragma mark - Action

- (void)tapToReset
{
//    NSLog(@"\nself.frame: %@\nself.bounds: %@\nself.contentOffset: %@\nself.contentSize: %@", NSStringFromCGRect(self.frame), NSStringFromCGRect(self.bounds), NSStringFromCGPoint(self.scrollView.contentOffset), NSStringFromCGSize(self.scrollView.contentSize));
}

- (void)crop
{
    CGFloat heightScale = _image.size.width / self.frame.size.width;
    CGFloat widthScale = _image.size.height / self.frame.size.height;
    CGFloat scale = MIN(widthScale, heightScale);
    
    _cropRect.size.width = (CGFloat)round(CGRectGetWidth(self.bounds)/self.zoomScale) * scale;
    _cropRect.size.height = (CGFloat)round(CGRectGetHeight(self.bounds)/self.zoomScale) * scale;
    _cropRect.origin.x = (CGFloat)round((self.contentOffset.x + self.contentInset.left)/self.zoomScale) * scale;
    _cropRect.origin.y = (CGFloat)round((self.contentOffset.y + self.contentInset.top)/self.zoomScale) * scale;
    
//    CGFloat scale = _scrollView.contentSize.width / self.frame.size.width;
//    
//    CGFloat widthScale = _image.size.width / self.bounds.size.width;
//    CGFloat heightScale = _image.size.height / self.bounds.size.height;
//    
//    CGFloat contentScale = MIN(widthScale, heightScale);
//    
//    CGFloat heightPerWidthRatio = self.frame.size.width / self.frame.size.height;
//    
//    NSLog(@"%@", NSStringFromUIEdgeInsets(_scrollView.contentInset));
//    
//    CGRect cropRect = CGRectMake(_scrollView.contentOffset.x / contentScale,
//                                 _scrollView.contentOffset.y / contentScale,
//                                 _image.size.width / self.bounds.size.width,
//                                 _image.size.height / self.bounds.size.height);
    if ([_delegate respondsToSelector:@selector(imageCropView:didCroppedWithRect:)]) {
        [_delegate imageCropView:self didCroppedWithRect:_cropRect];
    }
}

@end
