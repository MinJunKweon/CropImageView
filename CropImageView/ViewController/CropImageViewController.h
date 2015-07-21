//
//  CropImageViewController.h
//  CropImageView
//
//  Created by 1000732 on 2015. 7. 21..
//  Copyright (c) 2015년 1000732. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CropImageViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *imageScrollView;
@property (nonatomic, strong) UIImageView *imageView;

- (instancetype)init;

@end
