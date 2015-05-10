//
//  JSDrawableView.m
//  Labrary
//
//  Created by jacky.song on 12-11-23.
//  Copyright (c) 2012 symbio.com. All rights reserved.
//

#import "JSDrawableView.h"
#import <QuartzCore/QuartzCore.h>

@interface JSDrawableView (){
  BOOL quit;
}

@end

@implementation JSDrawableView{
    CADisplayLink *link;
    CGContextRef ctx;
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        link = [[CADisplayLink displayLinkWithTarget:self selector:@selector(drawCavans:)] retain];
    }
    return self;
}

- (void)dealloc{
    JS_releaseSafely(link);
    [super dealloc];
}

-(void)startDrawing{  
    ctx = CGContextCreate(self.bounds.size);
    
    // make transform to compatible with UIKit's coordination: Origin point at top-left corner.
    CGContextTranslateCTM(ctx, 0, self.bounds.size.height);
    CGContextScaleCTM(ctx, 1, -1);
    
    CGRect rect = self.bounds;
    
    NSTimeInterval interval = [self timeDrivenRefreshInterval];
    if (interval > 0) {
        
        // TODO: use display link to impl time driven drawing
        
        link.frameInterval = interval;
        [link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    }
    else{
        [self drawCavans:ctx rect:rect];
        [self renderToScreenWithDoneAction:^{
            CGContextRelease(ctx);
        }];
    }
}

- (void)drawCavans:(CADisplayLink*)sender {
    CGRect rect = self.bounds;

    [self cleanCavans:ctx rect:rect];
    
    [self drawCavans:ctx rect:rect];
    
    // The key to fast graphics on iOS is to do as little work with the software renderer (basically anything
    // in a CGContext) as you can.
    
    // set your view.layer.contents to your CGImageRef.
    // (And make sure to not override -drawRect:, not call -setNeedsDisplay, and make sure contentMode is not UIViewContentModeRedraw. Easier to just use UIImageView.)
    [self renderToScreenWithDoneAction:nil];
}

-(void)renderToScreenWithDoneAction:(dispatch_block_t)doneAction{
    CGImageRef img = CGBitmapContextCreateImage(ctx);
    self.layer.contents = (id)img;
    if (doneAction) doneAction();
}

#pragma mark public

-(void)quitDrivenLoop{
    [link invalidate];
    CGContextRelease(ctx);
}


#pragma mark subclass override

-(NSInteger)timeDrivenRefreshInterval{
  return 0;
}

-(void)cleanCavans:(CGContextRef) context rect:(CGRect)rect{
  
}

-(void)drawCavans:(CGContextRef) context rect:(CGRect)rect{
  
}

/*
 What happened when you draw a CGImage in drawRect: using the context returned by UIGraphicsGetCurrentContext:
 
 1.	UIKit makes a CGBitmapContext the size of your view's bounds, in device pixels
 2.	It makes that context the current context
 3.	You draw your CGImage into that context
 4.	... so CG has to rescale the source image, and touch all of the destination pixels
 5.	After you're done drawing, UIKit makes a CGImage from the bitmap context
 6.	and assigns it to the view's layer's contents.
 */

/*
 So how to accelarate?  Pass the image to the GPU directly. But How?
 If you want that to happen, you need to tell the system to do that, by cutting out some of the steps above.
 
 The easiest way would be to make a UIImageView, and set its image to a UIImage wrapping your CGImageRef.
 Or, set your view.layer.contents to your CGImageRef. (*AND* make sure to not override -drawRect:, not call -setNeedsDisplay, and make sure contentMode is not UIViewContentModeRedraw. Easier to just use UIImageView.)
 */


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
