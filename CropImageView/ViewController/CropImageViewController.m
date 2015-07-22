//
//  CropImageViewController.m
//  CropImageView
//
//  Created by 1000732 on 2015. 7. 21..
//  Copyright (c) 2015년 1000732. All rights reserved.
//

#import "CropImageViewController.h"

#import <Masonry/Masonry.h>

@interface CropImageViewController ()

@end

@implementation CropImageViewController

#pragma mark - Initializer

- (instancetype)init
{
    self = [super init];
    if (self) {
        _imageScrollView = [[UIScrollView alloc] init];
        _imageView = [[UIImageView alloc] init];
        _doneButton = [[UIButton alloc] init];
        _ltrbLabel = [[UILabel alloc] init];
        
        [self initialize];
        [self makeAutoLayoutConstraints];
        
        self.view.backgroundColor = [UIColor blackColor];
    }
    return self;
}

- (void)initialize
{
    UIImage *image = [UIImage imageNamed:@"image.png"];
    _imageView.image = image;
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    [_imageScrollView addSubview:_imageView];
    
    _imageScrollView.scrollEnabled = YES;
    _imageScrollView.showsHorizontalScrollIndicator = NO;
    _imageScrollView.showsVerticalScrollIndicator = NO;
    _imageScrollView.multipleTouchEnabled = YES;
    _imageScrollView.delegate = self;
    _imageScrollView.contentMode = UIViewContentModeScaleAspectFit;
    
    _doneButton.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    _doneButton.backgroundColor = [UIColor whiteColor];
    _doneButton.titleLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Light" size:30.0f];
    [_doneButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_doneButton setTitle:@"Done" forState:UIControlStateNormal];
    [_doneButton addTarget:self
                    action:@selector(done)
          forControlEvents:UIControlEventTouchUpInside];
    
    _ltrbLabel.textColor = [UIColor whiteColor];
    _ltrbLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Light" size:30.0f];
    _ltrbLabel.numberOfLines = 0;
    _ltrbLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.view addSubview:_imageScrollView];
    [self.view addSubview:_doneButton];
    [self.view addSubview:_ltrbLabel];
}

- (void)makeAutoLayoutConstraints
{
    [_imageScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.top.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_centerY).with.offset(20.0f);
    }];
    
    [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_imageScrollView);
    }];
    
    [_doneButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(10.0f);
        make.right.equalTo(self.view).with.offset(-10.0f);
        make.bottom.equalTo(self.view).with.offset(-30.0f);
    }];
    
    [_ltrbLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(10.0f);
        make.right.equalTo(self.view).with.offset(-10.0f);
        make.bottom.equalTo(_doneButton.mas_top).with.offset(-10.0f);
    }];
}

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CGFloat minScaleWidth = _imageScrollView.frame.size.width / _imageScrollView.contentSize.width;
    CGFloat minScaleHeight = _imageScrollView.frame.size.height / _imageScrollView.contentSize.height;
    
    _imageScrollView.minimumZoomScale = MAX(minScaleWidth, minScaleHeight);
    _imageScrollView.maximumZoomScale = 2.0f;
    _imageScrollView.zoomScale = _imageScrollView.minimumZoomScale;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

#pragma mark - Scroll View Delegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}

#pragma mark - Event

- (void)done
{
    _ltrbLabel.text = [NSString stringWithFormat:@"%@, %lf", NSStringFromCGPoint(_imageScrollView.contentOffset), _imageScrollView.zoomScale];
    NSLog(@"offset: %@", NSStringFromCGPoint(_imageScrollView.contentOffset));
    NSLog(@"scaleFactor: %lf", _imageScrollView.contentScaleFactor);
}

@end
