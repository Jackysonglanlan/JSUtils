//
//  JSSpriteLayer.m
//
//  Created by jackysong on 14-3-28.
//

#import "JSSpriteLayer.h"


@implementation JSSpriteLayer

@synthesize sampleIndex;

#pragma mark -
#pragma mark Initialization, variable sample size

+ (id)layerWithImage:(CGImageRef)img;
{
    JSSpriteLayer *layer = [(JSSpriteLayer*)[self alloc] initWithImage:img];
    return [layer autorelease];
}

- (id)initWithImage:(CGImageRef)img;
{
    self = [super init];
    if (self != nil)
    {
        self.contents = (id)img;
        sampleIndex = 1;
    }

    return self;
}

#pragma mark -
#pragma mark Initialization, fixed sample size

+ (id)layerWithImage:(CGImageRef)img sampleSize:(CGSize)size;
{
    JSSpriteLayer *layer = [[self alloc] initWithImage:img sampleSize:size];
    return [layer autorelease];
}

- (id)initWithImage:(CGImageRef)img sampleSize:(CGSize)size;
{
    self = [self initWithImage:img];
    if (self != nil)
    {
        CGSize sampleSizeNormalized = CGSizeMake(size.width/CGImageGetWidth(img), size.height/CGImageGetHeight(img));
        self.bounds = CGRectMake( 0, 0, size.width, size.height );
        self.contentsRect = CGRectMake( 0, 0, sampleSizeNormalized.width, sampleSizeNormalized.height );
    }
    
    return self;
}

#pragma mark - customize animation
#pragma mark Frame by frame animation


+ (BOOL)needsDisplayForKey:(NSString *)key;
{
    return [key isEqualToString:@"sampleIndex"];
}


// contentsRect or bounds changes are not animated
+ (id < CAAction >)defaultActionForKey:(NSString *)aKey;
{
    if ([aKey isEqualToString:@"contentsRect"] || [aKey isEqualToString:@"bounds"])
        return (id < CAAction >)[NSNull null];
    
    return [super defaultActionForKey:aKey];
}


- (unsigned int)currentSampleIndex;
{
    return ((JSSpriteLayer*)[self presentationLayer]).sampleIndex;
}


// Implement displayLayer: on the delegate to override how sample rectangles are calculated; remember to use currentSampleIndex, ignore sampleIndex == 0, and set the layer's bounds
- (void)display{
    
    // has delegate, ask it to set layer content
    if ([self.delegate respondsToSelector:@selector(displayLayer:)]){
        [self.delegate displayLayer:self];
        return;
    }
    
    // the sprite has the same size
    
    unsigned int currentSampleIndex = [self currentSampleIndex];
    if (!currentSampleIndex)
        return;
    
    CGSize sampleSize = self.contentsRect.size;
    self.contentsRect = CGRectMake(
        ((currentSampleIndex - 1) % (int)(1/sampleSize.width)) * sampleSize.width, 
        ((currentSampleIndex - 1) / (int)(1/sampleSize.width)) * sampleSize.height, 
        sampleSize.width, sampleSize.height
    );
    
//    NSLog(@"currentSampleIndex:%d contentsRect: %@",  currentSampleIndex, NSStringFromCGRect(self.contentsRect));
}


@end
