//
//	JS_Math_Geometry.h
//	JS_Math
//

#import <UIKit/UIKit.h>

////////////////////////////////////////
/////// Macros ////////
////////////////////////////////////////

#pragma mark - Macros

//////////// Line Calculation ////////////

#pragma mark line calculation

#define JS_Math_PointsDistance(p1,p2) sqrt( ((p1).x-(p2).x)*((p1).x-(p2).x) + ((p1).y-(p2).y)*((p1).y-(p2).y) )

#define JS_Math_SlopeRateOfLine(p1,p2) (((p2).y-(p1).y) / ((p2).x - (p1).x))

//////////// Triangle Calculation ////////////

#pragma mark triangle calculation

#define JS_Math_DegreesToRadians(degrees) ((degrees) * M_PI / 180)

#define JS_Math_RadiansToDegrees(radians) ((radians) * 180 / M_PI)

#define JS_Math_Triangle_CosineLaw_Radian_Opposite(side,adjacent1,adjacent2) \
  acosf( ((adjacent1)*(adjacent1) + (adjacent2)*(adjacent2) - (side)*(side)) / (2.0*(adjacent1)*(adjacent2)) )


//////////////////////////////////////////////////
/////// C functions  ////////
//////////////////////////////////////////////////

#pragma mark - C functions

//////////// Geometry Calculation ////////////

#pragma mark geometry calculation

CGPoint JS_Math_PointApplyOffset(CGPoint point, UIOffset offset);

UIEdgeInsets JS_Math_UniformEdgeInsetsMake(CGFloat inset);
UIEdgeInsets JS_Math_EdgeOutsetsMake(CGFloat top, CGFloat left, CGFloat bottom, CGFloat right);
UIEdgeInsets JS_Math_UniformEdgeOutsetsMake(CGFloat outset);
CGFloat JS_Math_SizeGetArea(CGSize size);
CGFloat JS_Math_RectsGetMaxHeight(const CGRect rects[], size_t count);
CGFloat JS_Math_RectsGetMaxWidth(const CGRect rects[], size_t count);
CGRect JS_Math_RectsUnion(const CGRect rects[], size_t count);
CGRect JS_Math_RectsIntersection(const CGRect rects[], size_t count);
CGFloat JS_Math_RectsGetMinX(const CGRect rects[], size_t count);
CGFloat JS_Math_RectsGetMidX(const CGRect rects[], size_t count);
CGFloat JS_Math_RectsGetMaxX(const CGRect rects[], size_t count);
CGFloat JS_Math_RectsGetMinY(const CGRect rects[], size_t count);
CGFloat JS_Math_RectsGetMidY(const CGRect rects[], size_t count);
CGFloat JS_Math_RectsGetMaxY(const CGRect rects[], size_t count);
CGFloat JS_Math_RectsGetWidth(const CGRect rects[], size_t count);
CGFloat JS_Math_RectsGetHeight(const CGRect rects[], size_t count);
// much faster than the "sqrt" way to calculate the distance between 2 points, but with about a 5% maximum error
int JS_Math_ApproximateDistance2D(int dx,int dy);
