//
//  ImageCropView.h
//  CropImageView
//
//  Created by 1000732 on 2015. 8. 3..
//  Copyright (c) 2015년 1000732. All rights reserved.
//

@class ImageCropView;

#import <UIKit/UIKit.h>

@protocol ImageCropViewDelegate <NSObject>

- (void)imageCropView:(ImageCropView *)imageCropView didCroppedWithRect:(CGRect)cropRect;

@end

@interface ImageCropView : UIView

@property (nonatomic) BOOL tapToResetEnabled;
@property (nonatomic, strong) UIImage *image;

@property (weak, nonatomic) id<ImageCropViewDelegate> delegate;

- (void)crop;

@end
