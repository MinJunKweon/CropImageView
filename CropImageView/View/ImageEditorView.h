//
//  ImageEditorView.h
//  CropImageView
//
//  Created by 1000732 on 2015. 7. 27..
//  Copyright (c) 2015년 1000732. All rights reserved.
//

@class ImageEditorView;

#import <UIKit/UIKit.h>

@protocol ImageEditorViewDelegate <NSObject>

- (void)imageEditorViewDidCropped:(ImageEditorView *)imageEditorView translate:(CGPoint)leftTopPoint scale:(CGFloat)scale angle:(CGFloat)angle;

@end

@interface ImageEditorView : UIView

@property (nonatomic, weak) id<ImageEditorViewDelegate> delegate;

@property (nonatomic, strong) UIImage *image;

@property (nonatomic) BOOL panEnabled;
@property (nonatomic) BOOL rotateEnabled;
@property (nonatomic) BOOL scaleEnabled;
@property (nonatomic) BOOL tapToResetEnabled;

@property (nonatomic) CGFloat minimumScale;
@property (nonatomic) CGFloat maximumScale;

- (void)reset:(BOOL)animated;
- (void)crop;

@end
