//
//  CropImageViewController.m
//  CropImageView
//
//  Created by 1000732 on 2015. 7. 21..
//  Copyright (c) 2015년 1000732. All rights reserved.
//

#import "CropImageViewController.h"
#import "CropImageView.h"

#import <Masonry/Masonry.h>

@interface CropImageViewController ()

@property (nonatomic, strong) UIView *borderView;

@end

@implementation CropImageViewController

#pragma mark - Initializer

- (instancetype)init
{
    self = [super init];
    if (self) {
        _imageView = [[CropImageView alloc] init];
        
        _borderView = [[UIView alloc] init];
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
    
    _borderView.backgroundColor = [UIColor whiteColor];
    
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
    
    [self.view addSubview:_imageView];
    [self.view addSubview:_borderView];
    [self.view addSubview:_doneButton];
    [self.view addSubview:_ltrbLabel];
}

- (void)makeAutoLayoutConstraints
{
    [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.left.and.right.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_centerY).with.offset(30.0f);
    }];
    
    [_borderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_imageView.mas_bottom);
        make.height.equalTo(@1.0f);
        make.left.and.right.equalTo(self.view);
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
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

#pragma mark - Event

- (void)done
{
    NSLog(@"before transform: %@", NSStringFromCGAffineTransform(_imageView.transform));
    [UIView animateWithDuration:.35f animations:^{
        _imageView.transform = CGAffineTransformMakeRotation(20/M_PI);
    }];
    NSLog(@"after transform: %@", NSStringFromCGAffineTransform(_imageView.transform));
    
//    _ltrbLabel.text = [NSString stringWithFormat:@"%@, %lf", NSStringFromCGPoint(_imageScrollView.contentOffset), _imageScrollView.zoomScale];
}

@end
