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

@property (nonatomic) CGFloat imageScale;

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
        
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    _maximumScale = 0.0f;
    
    _scrollView.delegate = self;
    _scrollView.minimumZoomScale = 1.0f;
    _scrollView.maximumZoomScale = 2.0f;
    _scrollView.clipsToBounds = YES;
    _scrollView.scrollsToTop = NO;
    _scrollView.bouncesZoom = NO;
    
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.frame = self.bounds;
    
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
    [self resetFrame];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self resetFrame];
    [self reset:NO];
}

- (void)layoutSubviews
{
    [self resetFrame];
}

- (void)resetFrame
{
    [self resume];
    
    _scrollView.frame = self.bounds;
    
    _imageScale = MIN(_image.size.width / self.bounds.size.width,
                      _image.size.height / self.bounds.size.height);
    
    CGSize imageViewSize = CGSizeMake(_image.size.width / _imageScale,
                                      _image.size.height / _imageScale);
    
    _scrollView.contentSize = imageViewSize;
    _imageView.frame = CGRectMake(0, 0,
                                  imageViewSize.width,
                                  imageViewSize.height);
    _scrollView.contentOffset = CGPointMake((imageViewSize.width - _scrollView.frame.size.width) / 2,
                                            (imageViewSize.height - _scrollView.frame.size.height) / 2);
}

#pragma mark - Scroll View Delegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}

#pragma mark - Gesture Action

- (void)tapToReset
{
    [self reset:YES];
}

#pragma mark - Action

- (void)pause
{
    _scrollView.scrollEnabled = NO;
}

- (void)resume
{
    _scrollView.scrollEnabled = YES;
}

- (void)reset:(BOOL)animated
{
    _scrollView.minimumZoomScale = 1.0f;
    
    if (_maximumScale < _scrollView.minimumZoomScale) {
        _scrollView.maximumZoomScale = NSIntegerMax;
    } else {
        _scrollView.maximumZoomScale = _maximumScale;
    }
    
    [_scrollView setZoomScale:_scrollView.minimumZoomScale animated:animated];
    
    CGPoint contentOffset = CGPointZero;
    contentOffset.x = (_scrollView.contentSize.width - (CGRectGetWidth(_scrollView.bounds) - _scrollView.contentInset.left - _scrollView.contentInset.right)) / 2.0f;
    contentOffset.y = (_scrollView.contentSize.height - (CGRectGetHeight(_scrollView.bounds) - _scrollView.contentInset.top - _scrollView.contentInset.bottom)) / 2.0f;
    contentOffset.x -= _scrollView.contentInset.left;
    contentOffset.y -= _scrollView.contentInset.top;
    [_scrollView setContentOffset:contentOffset animated:animated];
}

- (CGRect)crop
{
    CGFloat heightScale = _image.size.width / self.frame.size.width;
    CGFloat widthScale = _image.size.height / self.frame.size.height;
    CGFloat scale = MIN(widthScale, heightScale);
    
    CGRect cropRect;
    cropRect.size.width = (CGFloat)round(CGRectGetWidth(_scrollView.bounds)/_scrollView.zoomScale) * scale;
    cropRect.size.height = (CGFloat)round(CGRectGetHeight(_scrollView.bounds)/_scrollView.zoomScale) * scale;
    cropRect.origin.x = (CGFloat)round((_scrollView.contentOffset.x + _scrollView.contentInset.left)/_scrollView.zoomScale) * scale;
    cropRect.origin.y = (CGFloat)round((_scrollView.contentOffset.y + _scrollView.contentInset.top)/_scrollView.zoomScale) * scale;

    if ([_delegate respondsToSelector:@selector(imageCropView:didCroppedWithRect:)]) {
        [_delegate imageCropView:self didCroppedWithRect:cropRect];
    }
    return cropRect;
}

@end
