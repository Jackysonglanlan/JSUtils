//
//  UIImage+SLLEnhance.m
//  Labrary
//
//  Created by jacky.song on 12-11-28.
//  Copyright (c) 2012 symbio.com. All rights reserved.
//

#import "UIImage+SLLEnhance.h"
#import "JSMath.h"

@implementation UIImage(SLLEnhance)
+ (UIImage *)jsImageNamed:(NSString *)imageName {
    return [UIImage imageNamed:imageName];
}

static NSString *UIImage_SLLEnhance_bundlePath;
+ (UIImage *)jsImageNamed:(NSString*)imageName inBundle:(NSString*)bundleName{
    if (!UIImage_SLLEnhance_bundlePath) {
        UIImage_SLLEnhance_bundlePath = [[[NSBundle mainBundle] pathForResource:bundleName ofType:@"bundle"] retain];
    }
    NSString *imagePath = [UIImage_SLLEnhance_bundlePath stringByAppendingPathComponent:imageName];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    return image;
}

+ (UIImage*)jsImageWithResourcesPathCompontent:(NSString*)pathCompontent {
	return [UIImage imageWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:pathCompontent]];
}

+ (UIImage*)jsRotateImage:(UIImage*)image anchorPoint:(CGPoint)anchorPoint byDegrees:(NSUInteger)degrees{
    UIGraphicsBeginImageContext(image.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat anchorX = image.size.width * anchorPoint.x;
    CGFloat anchorY = image.size.height * anchorPoint.y;
    
    CGContextTranslateCTM(context, anchorX, anchorY);
    
    CGContextRotateCTM (context, JS_Math_DegreesToRadians(degrees));
    
    CGContextTranslateCTM(context, -anchorX, -anchorY);
    
    [image drawAtPoint:CGPointMake(0, 0)];
    
    return UIGraphicsGetImageFromCurrentImageContext();
}

+ (UIImage*)jsNoCacheImageNamed:(NSString*)name type:(NSString*)type{
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:type];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    return image;
}

- (void)jsCutTilesOfSize:(CGSize)size toDirectory:(NSString*)directoryPath usingPrefix:(NSString*)prefix
              onFinished:(void (^)(NSArray *tileFileNames))block{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CGFloat cols = self.size.width / size.width;
        CGFloat rows = self.size.height / size.height;
        
        int fullColumns = floorf(cols);
        int fullRows = floorf(rows);
        
        CGFloat remainderWidth = self.size.width - (fullColumns * size.width);
        CGFloat remainderHeight = self.size.height - (fullRows * size.height);
        
        if (cols > fullColumns) fullColumns++;
        if (rows > fullRows) fullRows++;
        
        CGImageRef fullImage = [self CGImage];
        
        NSMutableArray *names = [NSMutableArray arrayWithCapacity:fullRows*fullColumns];
        for (int y = 0; y < fullRows; ++y) {
            for (int x = 0; x < fullColumns; ++x) {
                CGSize tileSize = size;
                if (x + 1 == fullColumns && remainderWidth > 0) {
                    // Last column
                    tileSize.width = remainderWidth;
                }
                if (y + 1 == fullRows && remainderHeight > 0) {
                    // Last row
                    tileSize.height = remainderHeight;
                }
                
                NSString *path = [NSString stringWithFormat:@"%@/%@_%d_%d.png",directoryPath, prefix, x, y];
                
                // if exists
                if([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                    [names addObject:path];
                    continue;
                }
                
                CGImageRef tileImage = CGImageCreateWithImageInRect(fullImage,(CGRect){{x*size.width, y*size.height},tileSize});
                NSData *imageData = UIImagePNGRepresentation([UIImage imageWithCGImage:tileImage]);
                BOOL succ = [imageData writeToFile:path atomically:NO];
                if (succ) {
                    [names addObject:path];
                }
                CGImageRelease(tileImage);
            }
        }
        block(names);
    });
}

- (UIImage *)imageToFitSize:(CGSize)fitSize method:(MGImageResizingMethod)resizeMethod{
	float imageScaleFactor = [self scale];
    float sourceWidth = [self size].width * imageScaleFactor;
    float sourceHeight = [self size].height * imageScaleFactor;
    float targetWidth = fitSize.width;
    float targetHeight = fitSize.height;
    BOOL cropping = !(resizeMethod == MGImageResizeScale);
	
    // Calculate aspect ratios
    float sourceRatio = sourceWidth / sourceHeight;
    float targetRatio = targetWidth / targetHeight;
    
    // Determine what side of the source image to use for proportional scaling
    BOOL scaleWidth = (sourceRatio <= targetRatio);
    // Deal with the case of just scaling proportionally to fit, without cropping
    scaleWidth = (cropping) ? scaleWidth : !scaleWidth;
    
    // Proportionally scale source image
    float scalingFactor, scaledWidth, scaledHeight;
    if (scaleWidth) {
        scalingFactor = 1.0 / sourceRatio;
        scaledWidth = targetWidth;
        scaledHeight = round(targetWidth * scalingFactor);
    } else {
        scalingFactor = sourceRatio;
        scaledWidth = round(targetHeight * scalingFactor);
        scaledHeight = targetHeight;
    }
    float scaleFactor = scaledHeight / sourceHeight;
    
    // Calculate compositing rectangles
    CGRect sourceRect, destRect;
    if (cropping) {
        destRect = CGRectMake(0, 0, targetWidth, targetHeight);
        float destX, destY;
        if (resizeMethod == MGImageResizeCrop) {
            // Crop center
            destX = round((scaledWidth - targetWidth) / 2.0);
            destY = round((scaledHeight - targetHeight) / 2.0);
        } else if (resizeMethod == MGImageResizeCropStart) {
            // Crop top or left (prefer top)
            if (scaleWidth) {
				// Crop top
				destX = 0.0;
				destY = 0.0;
            } else {
				// Crop left
                destX = 0.0;
				destY = round((scaledHeight - targetHeight) / 2.0);
            }
        } else {
            // Crop bottom or right
            if (scaleWidth) {
				// Crop bottom
				destX = round((scaledWidth - targetWidth) / 2.0);
				destY = round(scaledHeight - targetHeight);
            } else {
				// Crop right
				destX = round(scaledWidth - targetWidth);
				destY = round((scaledHeight - targetHeight) / 2.0);
            }
        }
        sourceRect = CGRectMake(destX / scaleFactor, destY / scaleFactor,
                                targetWidth / scaleFactor, targetHeight / scaleFactor);
    } else {
        sourceRect = CGRectMake(0, 0, sourceWidth, sourceHeight);
        destRect = CGRectMake(0, 0, scaledWidth, scaledHeight);
    }
    
    UIGraphicsBeginImageContextWithOptions(destRect.size, NO, 0.0); // 0.0 for scale means "correct scale for device's main screen".
    
    CGImageRef sourceImg = CGImageCreateWithImageInRect([self CGImage], sourceRect); // cropping happens here.
    UIImage *image = [UIImage imageWithCGImage:sourceImg scale:0.0 orientation:self.imageOrientation]; // create cropped UIImage.
    [image drawInRect:destRect]; // the actual scaling happens here, and orientation is taken care of automatically.
    CGImageRelease(sourceImg);
    image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
	
    return image;
}


- (UIImage *)imageCroppedToFitSize:(CGSize)fitSize{
    return [self imageToFitSize:fitSize method:MGImageResizeCrop];
}


- (UIImage *)imageScaledToFitSize:(CGSize)fitSize{
    return [self imageToFitSize:fitSize method:MGImageResizeScale];
}

- (UIImage *)resizedImage:(CGSize)newSize
                transform:(CGAffineTransform)transform
           drawTransposed:(BOOL)transpose
     interpolationQuality:(CGInterpolationQuality)quality{
    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
    CGRect transposedRect = CGRectMake(0, 0, newRect.size.height, newRect.size.width);
    CGImageRef imageRef = self.CGImage;
    
    // Build a context that's the same dimensions as the new size
    CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                                newRect.size.width,
                                                newRect.size.height,
                                                CGImageGetBitsPerComponent(imageRef),
                                                0,
                                                CGImageGetColorSpace(imageRef),
                                                CGImageGetBitmapInfo(imageRef));
    
    // Rotate and/or flip the image if required by its orientation
    CGContextConcatCTM(bitmap, transform);
    
    // Set the quality level to use when rescaling
    CGContextSetInterpolationQuality(bitmap, quality);
    
    // Draw into the context; this scales the image
    CGContextDrawImage(bitmap, transpose ? transposedRect : newRect, imageRef);
    
    // Get the resized image from the context and a UIImage
    CGImageRef newImageRef = CGBitmapContextCreateImage(bitmap);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    
    // Clean up
    CGContextRelease(bitmap);
    CGImageRelease(newImageRef);
    
    return newImage;
}

-(UIImage*)alphaMask{
    // To show the difference with an image mask, we take the above image and process it to extract
    // the alpha channel as a mask.
    // Allocate data
    CGFloat w = self.size.width;
    CGFloat h = self.size.height;
    NSMutableData *data = [NSMutableData dataWithLength:w * h * 1];
    // Create a bitmap context
    CGContextRef context = CGBitmapContextCreate([data mutableBytes], w, h, 8, h, NULL, kCGImageAlphaOnly);
    // Set the blend mode to copy to avoid any alteration of the source data
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    // Draw the image to extract the alpha channel
    CGContextDrawImage(context, CGRectMake(0.0, 0.0, w, h), self.CGImage);
    // Now the alpha channel has been copied into our NSData object above, so discard the context and lets make an image mask.
    CGContextRelease(context);
    // Create a data provider for our data object (NSMutableData is tollfree bridged to CFMutableDataRef, which is compatible with CFDataRef)
    CGDataProviderRef dataProvider = CGDataProviderCreateWithCFData((CFMutableDataRef)data);
    // Create our new mask image with the same size as the original image
    CGImageRef maskingImage = CGImageMaskCreate(w, h, 8, 8, w, dataProvider, NULL, YES);
    // And release the provider.
    CGDataProviderRelease(dataProvider);
    
    UIImage *img = [UIImage imageWithCGImage:maskingImage];
    
    CGImageRelease(maskingImage);
    
    return img;
}

- (void)drawInRect:(CGRect)rect withAlphaMaskColor:(UIColor*)aColor{
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSaveGState(context);
	
	CGContextTranslateCTM(context, 0.0, rect.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	
	rect.origin.y = rect.origin.y * -1;
	const CGFloat *color = CGColorGetComponents(aColor.CGColor);
	CGContextClipToMask(context, rect, self.CGImage);
	CGContextSetRGBFillColor(context, color[0], color[1], color[2], color[3]);
	CGContextFillRect(context, rect);
	
	CGContextRestoreGState(context);
}

- (void)drawInRect:(CGRect)rect withAlphaMaskGradient:(NSArray*)colors{
	
	NSAssert([colors count]==2, @"an array containing two UIColor variables must be passed to drawInRect:withAlphaMaskGradient:");
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSaveGState(context);
	
	CGContextTranslateCTM(context, 0.0, rect.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	
	rect.origin.y = rect.origin.y * -1;
	
	CGContextClipToMask(context, rect, self.CGImage);
	
	const CGFloat *top = CGColorGetComponents(((UIColor*)[colors objectAtIndex:0]).CGColor);
	const CGFloat *bottom = CGColorGetComponents(((UIColor*)[colors objectAtIndex:1]).CGColor);
	
	CGColorSpaceRef _rgb = CGColorSpaceCreateDeviceRGB();
	size_t _numLocations = 2;
	CGFloat _locations[2] = { 0.0, 1.0 };
	CGFloat _colors[8] = { top[0], top[1], top[2], top[3], bottom[0], bottom[1], bottom[2], bottom[3] };
	CGGradientRef gradient = CGGradientCreateWithColorComponents(_rgb, _colors, _locations, _numLocations);
	CGColorSpaceRelease(_rgb);
	
	CGPoint start = CGPointMake(CGRectGetMidX(rect), rect.origin.y);
	CGPoint end = CGPointMake(CGRectGetMidX(rect), rect.size.height);
	
	CGContextClipToRect(context, rect);
	CGContextDrawLinearGradient(context, gradient, start, end, kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
	
	CGGradientRelease(gradient);
	
	CGContextRestoreGState(context);
	
}

@end
