//
//  UIImage+SLLEnhance.h
//  Labrary
//
//  Created by jacky.song on 12-11-28.
//  Copyright (c) 2012 symbio.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

CG_INLINE CGContextRef JS2D_CGContextCreate(CGSize size){
	CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
	CGContextRef ctx = CGBitmapContextCreate(nil, size.width, size.height, 8, size.width * (CGColorSpaceGetNumberOfComponents(space) + 1), space, kCGBitmapAlphaInfoMask);
	CGColorSpaceRelease(space);
    
	return ctx;
}

CG_INLINE UIImage* JS2D_GetImageFromContext(CGContextRef ctx){
	CGImageRef cgImage = CGBitmapContextCreateImage(ctx);
	UIImage* image = [UIImage imageWithCGImage:cgImage
                                         scale:[UIScreen mainScreen].scale
                                   orientation:UIImageOrientationUp];
	CGImageRelease(cgImage);
    
	return image;
}


typedef enum {
    MGImageResizeCrop,	// analogous to UIViewContentModeScaleAspectFill, i.e. "best fit" with no space around.
    MGImageResizeCropStart,
    MGImageResizeCropEnd,
    MGImageResizeScale	// analogous to UIViewContentModeScaleAspectFit, i.e. scale down to fit, leaving space around if necessary.
} MGImageResizingMethod;


@interface UIImage(SLLEnhance)
+ (UIImage *)jsImageNamed:(NSString *)imageName;

+ (UIImage *)jsImageNamed:(NSString*)imageName inBundle:(NSString*)bundleName;

+ (UIImage*)jsImageWithResourcesPathCompontent:(NSString*)pathCompontent;

+ (UIImage*)jsNoCacheImageNamed:(NSString*)name type:(NSString*)type;

+ (UIImage*)jsRotateImage:(UIImage*)image anchorPoint:(CGPoint)anchorPoint byDegrees:(NSUInteger)degrees;

- (void)jsCutTilesOfSize:(CGSize)size toDirectory:(NSString*)directoryPath usingPrefix:(NSString*)prefix
              onFinished:(void (^)(NSArray *tileFileNames))block;

- (UIImage *)imageToFitSize:(CGSize)size method:(MGImageResizingMethod)resizeMethod;
- (UIImage *)imageCroppedToFitSize:(CGSize)size; // uses MGImageResizeCrop
- (UIImage *)imageScaledToFitSize:(CGSize)size; // uses MGImageResizeScale

- (UIImage *)resizedImage:(CGSize)newSize
                transform:(CGAffineTransform)transform
           drawTransposed:(BOOL)transpose
     interpolationQuality:(CGInterpolationQuality)quality;

/*
 * Masks the context with the image, then fills with the color
 */
- (void)drawInRect:(CGRect)rect withAlphaMaskColor:(UIColor*)aColor;

/*
 * Masks the context with the image, then fills with the gradient (two colors in an array)
 */
- (void)drawInRect:(CGRect)rect withAlphaMaskGradient:(NSArray*)colors;

- (UIImage*)alphaMask;

@end

