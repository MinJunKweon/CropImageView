//
//  CropImageView.h
//  CropImageView
//
//  Created by 1000732 on 2015. 7. 22..
//  Copyright (c) 2015년 1000732. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CropImageView : UIImageView <UIGestureRecognizerDelegate>

/**
 * Maximum of zoom scale.
 *
 * @see 0 is default. if this set 0, non-maximum
 */
@property (nonatomic) CGFloat maximumScale;

- (instancetype)init;
- (instancetype)initWithImage:(UIImage *)image;

- (BOOL)isInvaildPosition;

@end
