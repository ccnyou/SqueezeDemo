//
//  UIImage+scale.h
//  SqueezeDemo
//
//  Created by 聪宁陈 on 2017/7/20.
//  Copyright © 2017年 ccnyou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (scale)
- (UIImage *)scaleToSize:(CGSize)size;
- (UIImage *)cropToSize:(CGSize)size;
+ (CVPixelBufferRef)pixelBufferFromCGImage:(UIImage *)originImage;

@end
