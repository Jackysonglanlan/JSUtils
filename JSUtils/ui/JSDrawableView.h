//
//  JSDrawableView.h
//  Labrary
//
//  Created by jacky.song on 12-11-23.
//  Copyright (c) 2012 symbio.com. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 Subclass should *never* override drawRect: method, use drawCavans:rect: instead.
 */
@interface JSDrawableView : UIView

-(void)startDrawing;

-(void)stop;

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
