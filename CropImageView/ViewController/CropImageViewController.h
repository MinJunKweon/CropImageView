//
//  CropImageViewController.h
//  CropImageView
//
//  Created by 1000732 on 2015. 7. 21..
//  Copyright (c) 2015년 1000732. All rights reserved.
//

@class ImageCropView;

#import <UIKit/UIKit.h>

@interface CropImageViewController : UIViewController

@property (nonatomic, strong) ImageCropView *imageEditorView;

@property (nonatomic, strong) UIButton *doneButton;
@property (nonatomic, strong) UILabel *ltrbLabel;

- (instancetype)init;

@end
