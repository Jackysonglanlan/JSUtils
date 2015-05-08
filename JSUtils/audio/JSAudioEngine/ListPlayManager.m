//
//  ListPlayManager.m
//  Labrary
//
//  Created by jacky.song on 13-4-22.
//  Copyright (c) 2013 symbio.com. All rights reserved.
//

#import "ListPlayManager.h"
#import "JSAudioEngine.h"

@interface ListPlayManager (){
    JSAudioEngine *engine;
    NSArray *playList;
    NSUInteger cursor;
    BOOL isPlaying,isFinished,isCancelled;
}

@end

@implementation ListPlayManager
@synthesize didFinishPlayingBlock;
@synthesize repeatPlaying;

- (id)initWithPlayList:(NSArray*)list{
    self = [super init];
    if (self) {
        engine = [JSAudioEngine sharedInstance];
        playList = [list retain];
        [self reset];
    }
    return self;
}

- (void)dealloc{
    JS_releaseSafely(didFinishPlayingBlock);
    JS_releaseSafely(playList);
    [super dealloc];
}

-(NSString*)play{
    if (isFinished) {
        return nil;
    }
    
    if (isCancelled) {
        return nil;
    }
    
    if (isPlaying) {
        return nil;
    }
    
    NSString *audio = playList[cursor];
    
    isPlaying = YES;

    [Executors dispatchAsync:DISPATCH_QUEUE_PRIORITY_DEFAULT task:^{
        [self playItemAt:cursor++ inList:playList];
        [self postPlayHandle];
    }];
        
    return audio;
}

-(void)cancel:(BOOL)forceStop{
    isCancelled = YES;
    if (forceStop) {
        [engine stopEffect];
    }
}

#pragma mark private

-(void)reset{
    cursor = 0;
    isFinished = NO;
    isCancelled = NO;
}

-(void)postPlayHandle{
    if (cursor == playList.count) {
        isFinished = YES;
        if (didFinishPlayingBlock) didFinishPlayingBlock();
        if (repeatPlaying) [self reset];
    }
}

-(void)executeCallback:(NSString*)selectorName withDelay:(NSTimeInterval)delay
              playList:(NSArray*)list itemIndex:(NSInteger)index{
    SEL selector = NSSelectorFromString(selectorName);
    
    // can't handle
    if (![engine.delegate respondsToSelector:selector]) {
      if (engine.delegate) {
        JS_Stub_Throw(@"JSCallback Error", @"JSAudioEngine'delegate %@ has no method %@", [engine.delegate class],selectorName);
      }
      else{
        JS_Stub_Throw(@"JSCallback Error", @"JSAudioEngine has NO delegate !");
      }
    }
    
    // need delay
    if (delay > 0) {
        // WARNing:
        // Can't use NSTimer or perfromSelector:withObject:afterDelay here,
        // For this method is runing on operation queue's thread, not main thread.
        
        // Stop the "play thread"
        [NSThread sleepForTimeInterval:delay];
    }
    
    [engine.delegate performSelector:selector];
    isPlaying = NO;
}

-(void)playItemAt:(NSInteger)itemIndex inList:(NSArray*)list{
    
    NSString *item = list[itemIndex];
    NSString *selectorName = nil;
    NSTimeInterval delay = -1;
    
    // case 1: JSCallback_methodName_delay_seconds
    if ([item isMatchedByRegex:JS_Regex_FullMatch(@"JSCallback_[^_]+(_delay_\\d+)?")]) {
        NSArray *arr = [item componentsSeparatedByString:@"_"];
        selectorName = arr[1];
        // count == 4 means it has delay property
        delay = (arr.count == 4) ? [[arr lastObject] doubleValue] : 0;
        [self executeCallback:selectorName withDelay:delay playList:list itemIndex:itemIndex];
        
        // no more process
        return;
    }
    
    // case 2: "with syntax": AudioName_with_methodName_delay_seconds
    if ([item isMatchedByRegex:JS_Regex_FullMatch(@"[^_]+_with_[^_]+(_delay_\\d+)?")]){
        NSArray *arr = [item componentsSeparatedByString:@"_"];
        item = arr[0];// change item to real audio name
        selectorName = (arr[2]);
        // count == 5 means it has delay property
        if (arr.count==5) {
            delay = [[arr lastObject] doubleValue];
        }
    }
    
    // case 2, delay != -1 means there is a delay callback follow the audio
    BOOL hasPostCallback = (delay != -1);
    

    // default case, assume the item is Audio name
    [engine playEffect:item slientFail:NO completion:^{
        // here, if the "play thread" is still waiting because of the delay, then code will be blocked here.
        // as soon as the thread is awaken, the code moves on
        // thus, we implement the behavior of "with syntax case 2"
        
        // here we check if there's delay callback after the audio playing, if isn't, we can set the flag
        if (!hasPostCallback) {
            isPlaying = NO;
        }
    }];
    
    if (hasPostCallback) {
        [self executeCallback:selectorName withDelay:delay playList:list itemIndex:itemIndex];
    }
}


@end
