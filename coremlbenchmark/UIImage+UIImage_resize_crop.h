//
//  UIImage+UIImage_resize_crop.h
//  coremlbenchmark
//
//  Created by Koan-Sin Tan on 2018/11/5.
//  Copyright © 2018 Koan-Sin Tan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (UIImage_resize_crop)

- (UIImage *) resizeTo: (CGSize) newSize;
- (UIImage *) cropToSquare;
- (CVPixelBufferRef) pixelBuffer;

@end

NS_ASSUME_NONNULL_END
