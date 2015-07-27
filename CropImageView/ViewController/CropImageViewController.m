//
//  CropImageViewController.m
//  CropImageView
//
//  Created by 1000732 on 2015. 7. 21..
//  Copyright (c) 2015년 1000732. All rights reserved.
//

#import "CropImageViewController.h"
//#import "CropImageView.h"
#import "ImageEditorView.h"

#import "DetailImageViewController.h"

#import <Masonry/Masonry.h>

@interface CropImageViewController () <ImageEditorViewDelegate>

@property (nonatomic, strong) UIImage *image;

@end

@implementation CropImageViewController

#pragma mark - Initializer

- (instancetype)init
{
    self = [super init];
    if (self) {
        _imageEditorView = [[ImageEditorView alloc] init];

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
    _image = [UIImage imageNamed:@"Square.png"];
    _imageEditorView.image = _image;
    _imageEditorView.maximumScale = 2.0f;
//    _imageEditorView.rotateEnabled = NO;
    _imageEditorView.delegate = self;
    
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
    
    [self.view addSubview:_imageEditorView];
    [self.view addSubview:_doneButton];
    [self.view addSubview:_ltrbLabel];
}

- (void)makeAutoLayoutConstraints
{
    [_imageEditorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.equalTo(@375.0f);
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
    [_imageEditorView setNeedsLayout];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark - Event

- (void)done
{
    /*
    if (_imageEditorView.frame.origin.y == 30.0f) {
        [_imageEditorView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@0);
            make.width.equalTo(@200.0f);
            make.height.equalTo(@200.0f);
        }];
    } else {
        [_imageEditorView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@30.0f);
            make.width.equalTo(@320.0f);
            make.height.equalTo(@320.0f);
        }];
    }
    */
    [_imageEditorView crop];
}

#pragma mark - Image Editor Delegate

- (void)imageEditorViewDidCropped:(ImageEditorView *)imageEditorView translate:(CGPoint)translation scale:(CGFloat)scale angle:(CGFloat)angle
{
    _ltrbLabel.text = [NSString stringWithFormat:@"{%lf, %lf}\n %lf, %lf", translation.x, translation.y, scale, angle];
    
#warning test
    CGPoint testPoint = CGPointMake(24.534655f, -12.077087);
    CGFloat testScale = 1.729562;
    CGFloat testAngle = 0.000000;
    DetailImageViewController *detailViewController = [[DetailImageViewController alloc] initWithImage:_image translate:testPoint scale:testScale angle:testAngle];
    
//    DetailImageViewController *detailViewController = [[DetailImageViewController alloc] initWithImage:_image translate:translation scale:scale angle:angle];
    
    [self presentViewController:detailViewController animated:NO completion:nil];
}

@end
