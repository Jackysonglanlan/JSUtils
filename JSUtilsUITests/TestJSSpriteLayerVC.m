//
//  TestJSSpriteLayer.m
//  JSUtils
//
//  Created by Song Lanlan on 10/5/15.
//  Copyright (c) 2015 Song Lanlan. All rights reserved.
//

#import "TestJSSpriteLayerVC.h"

#import "JSSpriteLayer.h"

@implementation TestJSSpriteLayerVC

- (id)init{
    self = [super init];
    if (self) {
        // Initialization code
        [self loadSprite];
    }
    return self;
}

- (void)loadSprite {
    CGImageRef richter2Img = [UIImage imageNamed:@"Richter2.png"].CGImage;
    JSSpriteLayer* richter2 = [JSSpriteLayer layerWithImage:richter2Img];
    richter2.position = CGPointMake(50, 100);
    richter2.delegate = self;
    
    // Both samples use the same animation
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"sampleIndex"];
    anim.fromValue = [NSNumber numberWithInt:0];
    anim.toValue = [NSNumber numberWithInt:12];
    anim.duration = 0.75f;
    anim.repeatCount = HUGE_VALF;
    
    [richter2 addAnimation:anim forKey:nil];
    
    [self.view.layer addSublayer:richter2];
}


// CALayer delegate needs this method for variable sample size to work
- (void)displayLayer:(CALayer *)layer;
{
    static const CGRect sampleRects[11] = {
        { 0, 0, 38, 47 },       // run
        { 0, 47, 46, 47 },
        { 82, 0, 40, 47 },
        { 122, 0, 30, 47 },
        { 152, 0, 36, 47 },
        { 38, 0, 44, 47 },
        { 188, 0, 42, 47 },
        { 230, 0, 26, 47 },
        { 46, 47, 28, 47 },     // idle
        { 74, 47, 28, 47 },
        { 102, 47, 28, 47 },
    };
    
    JSSpriteLayer *spriteLayer = (JSSpriteLayer*)layer;
    unsigned int idx = [spriteLayer currentSampleIndex];
    if (idx == 0)
        return;
    
//    DLog(@"currIndex:%d",idx);
    
    spriteLayer.bounds = CGRectMake(0, 0, sampleRects[idx-1].size.width, sampleRects[idx-1].size.height);
    
    spriteLayer.contentsRect = CGRectMake(sampleRects[idx-1].origin.x/256.0f, sampleRects[idx-1].origin.y/128.0f,
                                          sampleRects[idx-1].size.width/256.0f, sampleRects[idx-1].size.height/128.0f);
}

@end

