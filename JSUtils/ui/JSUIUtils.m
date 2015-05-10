//
//  JSUIUtils.m
//
//  Created by jackysong on 10-12-2.
//  Copyright 2010 sixclick. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "JSUIUtils.h"

@implementation JSUIUtils

#pragma mark coordinate

+(CGPoint)screenCenter:(BOOL)isVertical{
	CGRect appFrame = [UIScreen mainScreen].applicationFrame;
	if (isVertical) {
		return CGPointMake(appFrame.size.width/2, appFrame.size.height/2);
	}
	else {
		return CGPointMake(appFrame.size.height/2, appFrame.size.width/2);
	}
}

+(CGSize)screenSize:(BOOL)isVertical{
	CGRect appFrame = [UIScreen mainScreen].applicationFrame;
	if (isVertical) {
		return appFrame.size;
	}
	else {
		return CGSizeMake(appFrame.size.height, appFrame.size.width);
	}
}

/////   View   //////

#pragma mark view

+(void)randomBackground:(UIView *)view{
	view.backgroundColor = [UIColor colorWithRed:arc4random()%100*0.01
                                         green:arc4random()%100*0.01
                                          blue:arc4random()%100*0.01
                                         alpha:0.4];
}

+(BOOL)isSubviewOfView:(UIView *)view parent:(UIView *)superview{
	UIView *sv = view.superview;
	
	if (sv == nil) return NO;
	
	if (sv == superview) {
		return YES;
	}
	return [JSUIUtils isSubviewOfView:sv parent:superview];
}

+(BOOL)isHasSuperview:(UIView *)view ofType:(Class)clazz{
	UIView *sv = view.superview;
	
	if (sv == nil) return NO;
	
	if ([sv isKindOfClass:clazz]) {
		return YES;
	}
	return [JSUIUtils isHasSuperview:sv ofType:clazz];
}

#pragma mark layout

+ (NSArray*)geneEllipseLayoutInRect:(CGRect)rect scale:(NSInteger)scal blockSize:(CGSize)blockSize{
  NSMutableArray *arr = [NSMutableArray arrayWithCapacity:scal];
  
  CGPoint origin = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
  
  CGFloat w = CGRectGetWidth(rect);
  CGFloat h = CGRectGetHeight(rect);
  
  CGFloat longAxis = w/2;
  CGFloat shortAxis = h/2;
  
  CGPoint pointsOnCycle[scal];
  
  int i;
  for (i = 0 ; i < scal ; i++) {
    CGFloat radian = i * (2*M_PI / scal);
    // ellipse equation:
    //   x = original.x + a*cos∂
    //   y = original.y + b*sin∂ ( a is half of the longAxis, b is half of the shortAxis, ∂ <= PI && ∂ >= -PI )
    pointsOnCycle[i] = CGPointMake(origin.x + longAxis*cosf(radian), origin.y + shortAxis*sinf(radian));
  }
  
  for (i = 0; i < scal; i++) {
    CGPoint point = pointsOnCycle[i];
    [arr addObject:[NSValue valueWithCGRect:CGRectIntegral(CGRectMake(point.x - blockSize.width/2, point.y - blockSize.height/2, blockSize.width, blockSize.height))]];
  }
  
  return arr;
}

+(CGRect)calculateAreaBelow:(CGRect)area margin:(float_t)margin width:(float_t)w height:(float_t)h centerX:(float_t)cX{
	return CGRectMake(cX - w/2, area.origin.y+area.size.height+margin, w, h);
}

+(NSArray *)calculateMatrixLayoutOfViews:(NSInteger)initX
                                   initY:(NSInteger)initY
                                   count:(NSUInteger)count
                               viewWidth:(float_t)w
                              viewHeight:(float_t)h
                                paddingX:(float_t)pX
                                paddingY:(float_t)pY
                                  column:(NSUInteger)column
                                  inView:(UIView *)superView{
	// calculate layout
	float locXOffset = w+pX, locYOffset=h+pY;
	int colu=0, row=0;
	
	NSMutableArray *arr = [NSMutableArray arrayWithCapacity:count];
    int i;
	for (i=0;i<count;i++) {
		// locate view
		CGRect rect = CGRectMake(initX + locXOffset*colu++, initY + locYOffset*row, w, h);
		[arr addObject:[NSValue valueWithCGRect:rect]];
		// columns per row
		if (colu % column ==0) {
			colu=0;
			row++;
		}
	}
	return arr;
}


@end

////////////////////////////////////////
/////// UIViewController Enhancement ////////
////////////////////////////////////////

@implementation UIViewController(UIView_JSUIUtils)

+(id)initWithNibOfSameName{
  return [[self alloc] initWithNibName:[self description] bundle:nil];
}

@end

////////////////////////////////////////
/////// UIView Enhancement ////////
////////////////////////////////////////
#pragma mark - UIView Enhancement

@implementation UIView(UIView_JSUIUtils)

+(id)jsLoadFromNibOfSameName{
  return [[NSBundle mainBundle] loadNibNamed:[self.class description] owner:nil options:nil][0];
}


-(void)jsRoundCorner:(CGFloat)radius{
  [self.layer setCornerRadius:radius];
}

-(void)debug{
  [JSUIUtils randomBackground:self];
}

#pragma mark subviews

-(void)jsHideSubView:(NSInteger)subViewTag{
	[self viewWithTag:subViewTag].hidden=YES;
}

-(void)jsShowSubView:(NSInteger)subViewTag{
	[self viewWithTag:subViewTag].hidden=NO;
}

-(BOOL)jsIsContainsSubview:(NSInteger)subTag{
	return [self viewWithTag:subTag]!=nil;
}

- (NSArray*)jsAllSubviewsOfType:(Class)type{
  NSArray *subviews = self.subviews;
  NSMutableArray *arr = [NSMutableArray arrayWithCapacity:subviews.count];
  int i;
  for (i=0;i<subviews.count;i++){
    UIView *eachView = [subviews objectAtIndex:i];
    if ([eachView class]==type) {
      [arr addObject:eachView];
    }
  }
  return arr;
}

- (NSArray*)jsAllSubviews{
	NSArray *results = [self subviews];
  int i;
  for (i=0;i<results.count;i++){
    UIView *eachView = [results objectAtIndex:i];
		NSArray *riz = [eachView jsAllSubviews];
		if (riz) results = [results arrayByAddingObjectsFromArray:riz];
  }
	return results;
}

- (void)jsClearAllSubviewsOfType:(Class)type{
  NSArray *subviews = self.subviews;
  int i;
  for (i=0;i<subviews.count;i++){
    UIView *eachView = [subviews objectAtIndex:i];
    if ([eachView class]==type) {
      [eachView removeFromSuperview];
    }
  }
}

- (void)jsClearAllSubviews{
  NSArray *subviews = self.subviews;
  int i;
  for (i=0;i<subviews.count;i++){
    UIView *eachView = [subviews objectAtIndex:i];
    [eachView removeFromSuperview];
  }
}

- (NSArray*)jsViewPathFromWindow{
  NSMutableArray *array = [NSMutableArray arrayWithObject:self];
  UIView *view = self;
  UIWindow *window = self.window;
  while (view != window){
    view = [view superview];
    [array insertObject:view atIndex:0];
  }
  return array;
}

-(BOOL)jsIsSubviewOfView:(UIView *)superview{
  UIView *sv = self.superview;
	
	if (sv == nil) return NO;
	
	if (sv == superview) {
		return YES;
	}
	return [JSUIUtils isSubviewOfView:sv parent:superview];
}

-(BOOL)jsIsHasSuperviewOfType:(Class)clazz{
	UIView *sv = self.superview;
	
	if (sv == nil) return NO;
	
	if ([sv isKindOfClass:clazz]) {
		return YES;
	}
	return [JSUIUtils isHasSuperview:sv ofType:clazz];
}

- (void)jsAddMaskImage:(UIImage *)image{
    UIImageView *imageViewMask = [[[UIImageView alloc] initWithImage:image] autorelease];
    imageViewMask.userInteractionEnabled = YES;
    imageViewMask.frame = self.frame;
    self.layer.mask = imageViewMask.layer;
}

- (void)jsAddShadowWithColor:(UIColor *)color alpha:(CGFloat)alpha radius:(CGFloat)radius offset:(CGSize)offset{
  self.layer.shadowOpacity = alpha;
  self.layer.shadowRadius = radius;
  self.layer.shadowOffset = offset;
  
  if (color){
    self.layer.shadowColor = [color CGColor];
  }
  
  // cannot have masking
  self.layer.masksToBounds = NO;
}

-(void)jsAddGradientInRect:(CGRect)rect colors:(NSArray*)cgColors toLayerAt:(NSUInteger)index{
  CAGradientLayer *gradient = [CAGradientLayer layer];
  gradient.frame = rect;
  gradient.colors = cgColors;
  [self.layer insertSublayer:gradient atIndex:(unsigned)index];
}

/////////// attache object ///////////

-(void)jsAssociateParameterUsingRetain:(id)parameter key:(const void *)key{
  objc_setAssociatedObject(self, key, parameter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(void)jsAssociateParameterUsingAssign:(id)parameter key:(const void *)key{
  objc_setAssociatedObject(self, key, parameter, OBJC_ASSOCIATION_ASSIGN);
}

-(id)jsGetAssociatedParameter:(const void*)key{
  return objc_getAssociatedObject(self, key);
}

-(void)jsRemoveAssignAssociatedParameter:(const void*)key{
  objc_setAssociatedObject(self, key, nil, OBJC_ASSOCIATION_ASSIGN);
}

-(void)jsRemoveRetainAssociatedParameter:(const void*)key{
  objc_setAssociatedObject(self, key, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

