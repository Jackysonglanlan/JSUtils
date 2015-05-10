//
//  JSDrawableView.h
//  Labrary
//
//  Created by jacky.song on 12-11-23.
//  Copyright (c) 2012 symbio.com. All rights reserved.
//

#import <UIKit/UIKit.h>


CG_INLINE CGContextRef CGContextCreate(CGSize size){
	CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
	CGContextRef ctx = CGBitmapContextCreate(nil, size.width, size.height, 8, size.width * (CGColorSpaceGetNumberOfComponents(space) + 1),
                                             space, kCGImageAlphaPremultipliedLast);
	CGColorSpaceRelease(space);
  
	return ctx;
}

CG_INLINE UIImage* UIGraphicsGetImageFromContext(CGContextRef ctx){
	CGImageRef cgImage = CGBitmapContextCreateImage(ctx);
	UIImage* image = [UIImage imageWithCGImage:cgImage scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
	CGImageRelease(cgImage);
  
	return image;
}


/*
 Subclass should *never* override drawRect: method, use drawCavans:rect: instead.
 */
@interface JSDrawableView : UIView

-(void)startDrawing;

-(void)quitDrivenLoop;

#pragma mark subclass override

/**
 * See CADisplayLink's frameInterval.
 *
 * return 0 if you don't want to time-driven feature
 */
-(NSInteger)timeDrivenRefreshInterval;

// draw your contents here!
-(void)drawCavans:(CGContextRef) context rect:(CGRect)rect;

@end
