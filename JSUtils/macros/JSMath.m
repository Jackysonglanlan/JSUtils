//
//	JS_Math_Geometry.h
//	JS_Math
//
//	Copyright (c) 2012 Michael Potter
//	http://lucas.tiz.ma
//	lucas@tiz.ma
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//	FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "JSMath.h"

 CGPoint JS_Math_PointApplyOffset(CGPoint point, UIOffset offset){
	point.x += offset.horizontal;
	point.y += offset.vertical;

	return point;
}

 UIEdgeInsets JS_Math_UniformEdgeInsetsMake(CGFloat inset){
	return UIEdgeInsetsMake(inset, inset, inset, inset);
}

 UIEdgeInsets JS_Math_EdgeOutsetsMake(CGFloat top, CGFloat left, CGFloat bottom, CGFloat right){
	return UIEdgeInsetsMake(-top, -left, -bottom, -right);
}

 UIEdgeInsets JS_Math_UniformEdgeOutsetsMake(CGFloat outset){
	return UIEdgeInsetsMake(-outset, -outset, -outset, -outset);
}

 CGFloat JS_Math_SizeGetArea(CGSize size){
	return (size.width * size.height);
}

 CGFloat JS_Math_RectsGetMaxHeight(const CGRect rects[], size_t count){
	CGFloat maxHeight = 0.0f;

	for (NSUInteger i = 0; i < count; i++)	{
		if (rects[i].size.height > maxHeight)		{
			maxHeight = rects[i].size.height;
		}
	}

	return maxHeight;
}

 CGFloat JS_Math_RectsGetMaxWidth(const CGRect rects[], size_t count){
	CGFloat maxWidth = 0.0f;

	for (NSUInteger i = 0; i < count; i++)	{
		if (rects[i].size.width > maxWidth)		{
			maxWidth = rects[i].size.width;
		}
	}

	return maxWidth;
}

 CGRect JS_Math_RectsUnion(const CGRect rects[], size_t count){
	CGRect rectsUnion = CGRectNull;

	for (NSUInteger i = 0; i < count; i++)	{
		rectsUnion = CGRectUnion(rectsUnion, rects[i]);
	}

	return rectsUnion;
}

 CGRect JS_Math_RectsIntersection(const CGRect rects[], size_t count){
	CGRect rectsIntersection = CGRectNull;

	for (NSUInteger i = 0; i < count; i++)	{
		rectsIntersection = CGRectIntersection(rectsIntersection, rects[i]);
	}

	return rectsIntersection;
}

 CGFloat JS_Math_RectsGetMinX(const CGRect rects[], size_t count){
	return CGRectGetMinX(JS_Math_RectsUnion(rects, count));
}

 CGFloat JS_Math_RectsGetMidX(const CGRect rects[], size_t count){
	return CGRectGetMidX(JS_Math_RectsUnion(rects, count));
}

 CGFloat JS_Math_RectsGetMaxX(const CGRect rects[], size_t count){
	return CGRectGetMaxX(JS_Math_RectsUnion(rects, count));
}

 CGFloat JS_Math_RectsGetMinY(const CGRect rects[], size_t count){
	return CGRectGetMinY(JS_Math_RectsUnion(rects, count));
}

 CGFloat JS_Math_RectsGetMidY(const CGRect rects[], size_t count){
	return CGRectGetMidY(JS_Math_RectsUnion(rects, count));
}

 CGFloat JS_Math_RectsGetMaxY(const CGRect rects[], size_t count){
	return CGRectGetMaxY(JS_Math_RectsUnion(rects, count));
}

 CGFloat JS_Math_RectsGetWidth(const CGRect rects[], size_t count){
	return CGRectGetWidth(JS_Math_RectsUnion(rects, count));
}

 CGFloat JS_Math_RectsGetHeight(const CGRect rects[], size_t count){
	return CGRectGetHeight(JS_Math_RectsUnion(rects, count));
}

// much faster than the "sqrt" way to calculate the distance between 2 points, but with about a 5% maximum error
 int JS_Math_ApproximateDistance2D(int dx,int dy){  
  int min,max;  
  
  if(dx < 0){  
    dx=-dx;  
  }  
  if(dy < 0){  
    dy=-dy;  
  }  
  if(dx < dy){  
    min=dx;  
    max=dy;  
  }  
  else{  
    min=dy;  
    max=dx;  
  }  
  // coefficients equivalent to ( 123/128 * max ) and ( 51/128 * min )  
  return(((max << 8) + (max << 3) - (max << 4) - (max << 1) + (min << 7) - (min << 5) + (min << 3) - (min << 1)) >> 8);  
}
