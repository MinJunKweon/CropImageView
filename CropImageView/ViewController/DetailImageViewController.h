//
//  DetailImageViewController.h
//  CropImageView
//
//  Created by 1000732 on 2015. 7. 27..
//  Copyright (c) 2015년 1000732. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailImageViewController : UIViewController

@property (nonatomic, strong) UIImage *image;

@property (nonatomic) CGFloat angle;
@property (nonatomic) CGFloat scale;
@property (nonatomic) CGPoint translation;

@property (nonatomic) CGRect rect;

//- (instancetype)initWithImage:(UIImage *)image translate:(CGPoint)translation scale:(CGFloat)scale angle:(CGFloat)angle;
- (instancetype)initWithImage:(UIImage *)image rect:(CGRect)rect;

@end
