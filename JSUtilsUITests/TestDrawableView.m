//
//  TestDrawableView.m
//  Labrary
//
//  Created by jacky.song on 12-11-23.
//  Copyright (c) 2012年 symbio.com. All rights reserved.
//

#import "TestDrawableView.h"

@interface TestDrawableView (){
  CGPoint target;
  CGPoint lastPos;
  CGFloat boxSize;
  CGFloat xOffset, yOffset;
}

@end

@implementation TestDrawableView

- (id)initWithFrame:(CGRect)frame{
  self = [super initWithFrame:frame];
  if (self) {
    // Initialization code
    self.backgroundColor = [UIColor yellowColor];
    target = CGPointZero;
    lastPos = CGPointZero;
    boxSize = 20;
    
    [self startDrawing];
      
    UIButton *btn = [UIButton buttonWithType:(UIButtonTypeRoundedRect)];
    btn.frame = CGRectMake(0, 0, 50, 50);
    btn.tag = 1;
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"+++" forState:UIControlStateNormal];
    [self addSubview:btn];

    UIButton *btnMinus = [UIButton buttonWithType:(UIButtonTypeRoundedRect)];
    btnMinus.frame = CGRectMake(150, 0, 50, 50);
    [btnMinus addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [btnMinus setTitle:@"---" forState:UIControlStateNormal];
    [self addSubview:btnMinus];
  }
  return self;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
  if (touches.count != 1) return;
  
  UITouch *touch = [touches anyObject];
  CGPoint p = [touch locationInView:touch.view];
  [NSStringFromCGPoint(p) log];
  target = p;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
  UITouch *touch = [touches anyObject];
  CGPoint p = [touch locationInView:touch.view];
  lastPos = p;
}

#pragma mark calculation

-(void)controlAfterClick:(CGPoint)currPos{
  CGFloat error = 1;
  CGFloat speed = 1;
  
  if (!CGPointEqualToPoint(target, CGPointZero)) {
    if (currPos.x < target.x - error) {
      xOffset+=speed;
    }
    else if (currPos.x > target.x + error){
      xOffset-=speed;
    }
    
    if (currPos.y < target.y - error) {
      yOffset+=speed;
    }
    else if (currPos.y > target.y + error){
      yOffset-=speed;
    }
  }
}

#pragma mark delegate

-(void)btnClick:(UIView*)btn{
  boxSize += btn.tag == 1 ? 1 : -1;
}

#pragma mark override

-(NSInteger)timeDrivenRefreshInterval{
  return 1;
}

-(void)cleanCavans:(CGContextRef) context rect:(CGRect)rect{
  CGContextSetFillColorWithColor(context, self.backgroundColor.CGColor);
  CGContextFillRect(context, rect);
}

// draw your contents here!
-(void)drawCavans:(CGContextRef) context rect:(CGRect)rect{  
  //  [self addRoundedRect:context rect:rect cornerRadius:30];
    
  CGFloat margin = 10;
  CGFloat w = CGRectGetWidth(rect);
  CGFloat h = CGRectGetHeight(rect);
  
  NSInteger row = floorf(w / (boxSize+margin));
  NSInteger col = floorf(h / (boxSize+margin));
  
  //[self controlAfterClick:CGPointMake(currX, currY)];
  
  CGRect arr[col];
  
  NSInteger rand = boxSize/2;
  for (int i=0; i<row; i++) {
    for (int j=0; j<col; j++) {
      CGFloat x = (target.x - lastPos.x) + ((boxSize+margin)*i) + arc4random() % rand;
      CGFloat y = (target.y - lastPos.y) + ((boxSize+margin)*j) + arc4random() % rand;
      arr[j] = CGRectMake(x, y, boxSize, boxSize);
    }
    CGContextAddRects(context, arr, sizeof(arr) / sizeof(arr[0]));
  }
  
  //  CGContextSaveGState(context);
  
  CGContextStrokePath(context);
  
  //  CGContextRestoreGState(context);
  
  //  CGContextEOClip(context);
  
//      UIImage *img = [UIImage imageNamed:@"test.jpg"];
//      CGContextDrawImage(context, rect, img.CGImage);
  
  //  CGContextClipToRect(context, rect);

}

-(void)addRoundedRect:(CGContextRef)ctx rect:(CGRect)rect cornerRadius:(CGFloat)cornerRadius {
  if (cornerRadius <= 2.0) {
    CGContextAddRect(ctx, rect);
  }
  else {
    float x_left = rect.origin.x;
    float x_left_center = x_left + cornerRadius;
    float x_right_center = x_left + rect.size.width - cornerRadius;
    float x_right = x_left + rect.size.width;
    float y_top = rect.origin.y;
    float y_top_center = y_top + cornerRadius;
    float y_bottom_center = y_top + rect.size.height - cornerRadius;
    float y_bottom = y_top + rect.size.height;
    /* Begin path */
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, x_left, y_top_center);
    /* First corner */
    CGContextAddArcToPoint(ctx, x_left, y_top, x_left_center, y_top, cornerRadius);
    CGContextAddLineToPoint(ctx, x_right_center, y_top);
    /* Second corner */
    CGContextAddArcToPoint(ctx, x_right, y_top, x_right, y_top_center, cornerRadius);
    CGContextAddLineToPoint(ctx, x_right, y_bottom_center);
    /* Third corner */
    CGContextAddArcToPoint(ctx, x_right, y_bottom, x_right_center, y_bottom, cornerRadius);
    CGContextAddLineToPoint(ctx, x_left_center, y_bottom);
    /* Fourth corner */
    CGContextAddArcToPoint(ctx, x_left, y_bottom, x_left, y_bottom_center, cornerRadius);
    CGContextAddLineToPoint(ctx, x_left, y_top_center);
    /* Done */
    CGContextClosePath(ctx);
  }
}

@end
