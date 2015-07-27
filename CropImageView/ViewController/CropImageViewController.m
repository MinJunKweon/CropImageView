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

#import <Masonry/Masonry.h>

@interface CropImageViewController ()

@end

@implementation CropImageViewController

#pragma mark - Initializer

- (instancetype)init
{
    self = [super init];
    if (self) {
        _imageEditorView = [[ImageEditorView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];

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
    _imageEditorView.image = image;
    _imageEditorView.maximumScale = 2.0f;
    
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
        make.height.equalTo(@320.0f);
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

#pragma mark - Event

- (void)done
{
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
}

@end
