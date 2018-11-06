//
//  UIImage+UIImage_resize_crop.m
//  coremlbenchmark
//
//  Created by Koan-Sin Tan on 2018/11/5.
//  Copyright © 2018 Koan-Sin Tan. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import <CoreVideo/CoreVideo.h>

#import "UIImage+UIImage_resize_crop.h"

@implementation UIImage (UIImage_resize_crop)
- (UIImage *) resizeTo: (CGSize) newSize
{
    UIGraphicsBeginImageContextWithOptions(newSize, true, 1.0);
    [self drawInRect: CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resizedImage;
}

- (UIImage *) cropToSquare
{
    CGImageRef cgImage = self.CGImage;
    float imageHeight = self.size.height;
    float imageWidth = self.size.width;
    
    if (imageHeight > imageWidth)
        imageHeight = imageWidth;
    else
        imageWidth = imageHeight;
    
    CGSize size = CGSizeMake(imageWidth, imageHeight);
    
    CGFloat x = round((CGImageGetWidth(cgImage) - size.width) / 2);
    CGFloat y = round((CGImageGetHeight(cgImage) - size.height) / 2);
    
    CGRect cropRect = CGRectMake(x, y, size.width, size.height);
    CGImageRef croppedImage = CGImageCreateWithImageInRect(cgImage, cropRect);
    
    if (croppedImage != nil)
        return [UIImage imageWithCGImage: croppedImage scale: 0 orientation: self.imageOrientation];
    else
        return nil;
}

- (CVPixelBufferRef) pixelBuffer
{
    CGFloat width = self.size.width;
    CGFloat height = self.size.height;
    
    CFStringRef keys[2] = {kCVPixelBufferCGImageCompatibilityKey,kCVPixelBufferCGBitmapContextCompatibilityKey};
    CFBooleanRef vals[2] = {kCFBooleanTrue, kCFBooleanTrue};
    
    CFDictionaryRef attrs = CFDictionaryCreate(NULL, (const void **) keys, (const void **) vals, 2, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    CVPixelBufferRef pixelBuffer;
    CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32ARGB, attrs, &pixelBuffer);

    CVPixelBufferLockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
    void *pixelData = CVPixelBufferGetBaseAddress(pixelBuffer);
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(pixelData, width, height, 8, CVPixelBufferGetBytesPerRow(pixelBuffer), rgbColorSpace, kCGImageAlphaNoneSkipFirst);
    
    CGContextTranslateCTM(context, 0, height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    UIGraphicsPushContext(context);
    [self drawInRect: CGRectMake(0, 0, width, height)];
    UIGraphicsPopContext();
    CVPixelBufferUnlockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
    
    return pixelBuffer;
}

@end
