//
//  JSSpriteLayer.h
//
//  Created by jackysong on 14-3-28.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface JSSpriteLayer : CALayer {
    unsigned int sampleIndex;
}

// SampleIndex needs to be > 0
@property (readwrite, nonatomic) unsigned int sampleIndex; 

// For use with sample rects set by the delegate
+ (id)layerWithImage:(CGImageRef)img;
- (id)initWithImage:(CGImageRef)img;

// If all samples are the same size 
+ (id)layerWithImage:(CGImageRef)img sampleSize:(CGSize)size;
- (id)initWithImage:(CGImageRef)img sampleSize:(CGSize)size;

// Use this method instead of sprite.sampleIndex to obtain the index currently displayed on screen
- (unsigned int)currentSampleIndex; 


@end
