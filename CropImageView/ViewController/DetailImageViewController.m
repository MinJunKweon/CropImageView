//
//  DetailImageViewController.m
//  CropImageView
//
//  Created by 1000732 on 2015. 7. 27..
//  Copyright (c) 2015년 1000732. All rights reserved.
//

#import "DetailImageViewController.h"

#import <Masonry/Masonry.h>

@interface DetailImageViewController ()

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UIView *borderView;

@property (nonatomic, strong) UIButton *closeButton;

@end

@implementation DetailImageViewController

#pragma mark - Initializer

- (instancetype)init
{
    return [self initWithImage:nil translate:CGPointZero scale:0.0f angle:0.0f];
}

- (instancetype)initWithImage:(UIImage *)image translate:(CGPoint)translation scale:(CGFloat)scale angle:(CGFloat)angle
{
    self = [super init];
    if (self) {
        self.image = image;
        self.translation = translation;
        self.scale = scale;
        self.angle = angle;
        
        _imageView = [[UIImageView alloc] initWithImage:image];
        _borderView = [[UIView alloc] init];
        _closeButton = [[UIButton alloc] init];
        
        [self initialize];
        [self makeAutoLayoutConstraints];
        
        self.view.backgroundColor = [UIColor blackColor];
    }
    return self;
}

- (void)initialize
{
    _borderView.backgroundColor = [UIColor blackColor];
    
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    _closeButton.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    _closeButton.backgroundColor = [UIColor whiteColor];
    _closeButton.titleLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Light" size:30.0f];
    [_closeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_closeButton setTitle:@"Close" forState:UIControlStateNormal];
    [_closeButton addTarget:self
                    action:@selector(close)
          forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_imageView];
    [self.view addSubview:_borderView];
    [self.view addSubview:_closeButton];
}

- (void)makeAutoLayoutConstraints
{
    [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.right.and.left.equalTo(self.view);
        make.height.equalTo(@375.0f);
    }];
    
    [_borderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_imageView.mas_bottom);
        make.left.and.right.and.bottom.equalTo(self.view);
    }];
    
    [_closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(10.0f);
        make.right.equalTo(self.view).with.offset(-10.0f);
        make.bottom.equalTo(self.view).with.offset(-30.0f);
    }];
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _imageView.transform = CGAffineTransformIdentity;
    
    if (_translation.x && _translation.y) {
        _imageView.transform = CGAffineTransformTranslate(_imageView.transform, _translation.x, _translation.y);
    }
    if (_angle) {
        _imageView.transform = CGAffineTransformRotate(_imageView.transform, _angle);
    }
    if (_scale) {
        _imageView.transform = CGAffineTransformScale(_imageView.transform, _scale, _scale);
    }
}

#pragma mark - Event

- (void)close
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end
