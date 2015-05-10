//
//  JSUIUtils.h
//
//  Created by jackysong on 10-12-2.
//  Copyright 2010 sixclick. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface JSUIUtils : NSObject {
  
}

+(CGPoint)screenCenter:(BOOL)isVertical;

+(CGSize)screenSize:(BOOL)isVertical;

+(void)randomBackground:(UIView *)view;

/////   Layout   //////

// Draw a series of CGRect that form an internal-tangent ellipse layout of the given rect.
// If the rect is a square, the layout is an internal-tangent cycle
+ (NSArray*)geneEllipseLayoutInRect:(CGRect)rect scale:(NSInteger)scal blockSize:(CGSize)blockSize;

+ (CGRect)calculateAreaBelow:(CGRect)area
                      margin:(float_t)margin
                       width:(float_t)w
                      height:(float_t)h
                     centerX:(float_t)cX;

+ (NSArray *)calculateMatrixLayoutOfViews:(NSInteger)initX
                                    initY:(NSInteger)initY
                                    count:(NSUInteger)count
                                viewWidth:(float_t)w
                               viewHeight:(float_t)h
                                 paddingX:(float_t)pX
                                 paddingY:(float_t)pY
                                   column:(NSUInteger)column
                                   inView:(UIView *)superView;

@end

#pragma mark UIViewController

////////////////////////////////////////
/////// UIViewController Enhancement ////////
////////////////////////////////////////

@interface UIViewController(UIView_JSUIUtils)

+(id)initWithNibOfSameName;

@end

#pragma mark UIView

////////////////////////////////////////
/////// UIView Enhancement ////////
////////////////////////////////////////

@interface UIView(UIView_JSUIUtils)

+(id)jsLoadFromNibOfSameName;

-(void)jsRoundCorner:(CGFloat)radius;

// add random half-transparent background color to make debug easily
-(void)debug;

-(void)jsHideSubView:(NSInteger)subViewTag;
-(void)jsShowSubView:(NSInteger)subViewTag;
-(BOOL)jsIsContainsSubview:(NSInteger)subTag;

- (NSArray*)jsAllSubviewsOfType:(Class)type;
- (NSArray*)jsAllSubviews;
- (void)jsClearAllSubviewsOfType:(Class)type;
- (void)jsClearAllSubviews;

- (NSArray*)jsViewPathFromWindow;

/*
 recurisive
 */
-(BOOL)jsIsSubviewOfView:(UIView *)superview;

/*
 recurisive
 */
-(BOOL)jsIsHasSuperviewOfType:(Class)clazz;

- (void)jsAddMaskImage:(UIImage *)image;

/** Adds a layer-based shadow to the receiver.
 The advantage of using this method is that you do not need to import the QuartzCore headers just for adding the shadow.
 Layer-based shadows are properly combined for views that are on the same superview. This does not add a shadow path,
 you should call updateShadowPathToBounds whenever the receiver's bounds change and also after setting the initial frame.
 @warn Disables clipping to bounds because this would also clip off the shadow.
 @param color The shadow color. Can be `nil` for default black.
 @param alpha The alpha value of the shadow.
 @param radius The amount that the shadow is blurred.
 @param offset The offset of the shadow
 @see updateShadowPathToBounds
 */
- (void)jsAddShadowWithColor:(UIColor *)color alpha:(CGFloat)alpha radius:(CGFloat)radius offset:(CGSize)offset;

-(void)jsAddGradientInRect:(CGRect)rect colors:(NSArray*)cgColors toLayerAt:(NSUInteger)index;

/////////// attache object ///////////

-(void)jsAssociateParameterUsingRetain:(id)parameter key:(const void*)key;

-(void)jsAssociateParameterUsingAssign:(id)parameter key:(const void*)key;

-(id)jsGetAssociatedParameter:(const void*)key;

-(void)jsRemoveAssignAssociatedParameter:(const void*)key;

-(void)jsRemoveRetainAssociatedParameter:(const void*)key;

@end



