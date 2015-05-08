//
//  JSAudioEngine.h
//  Labrary
//
//  Created by jacky.song on 13-2-6.
//  Copyright (c) 2013 symbio.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"

#import "ObjectAL.h"
#import "OALTools.h"

#import "RegexKitLite.h"
#import "Executors.h"

#import "ListPlayManager.h"

//@protocol JSAudioEngineDelegate <NSObject>
//
//@end


/*
 Supported actions in PlayList:
 
 JSCallback:
 Format: JSCallback_methodName, may have suffix _delay_seconds
 Usage: Executes a method, execution can be delayed.
 NOTE: delegate should implement a method with signature which has the same name with methodName.
 
 "with syntax":
 Format: AudioName_with_methodName, may have suffix _delay_seconds
 Usage: Executes a method while playing the audio, method execution can be delayed.
 Behavior Example (foo_with_bar_delay_4):
 Case 1: audio play time is LONGER than execution delay time
 Start                                           END
 foo(Audio)    |----------------------------------------------|
 bar(Method)   |... 4 seconds delay ... *Run* .... wait ....  |
 
 Case 2: audio play time is SHORTER than execution delay time
 Start                           END
 foo(Audio)    |------------ .... wait ....   |
 bar(Method)   |... 4 seconds delay ... *Run* |
 
 
 
 */
@interface JSAudioEngine : NSObject

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(JSAudioEngine);

@property(nonatomic,readonly) OALAudioTrack *bgTrack;
@property(nonatomic,readonly) ALSource *effectTrack;
@property(nonatomic,readonly) BOOL isCancelled;

@property(nonatomic,assign) id delegate;

-(void)releaseResources;

-(void)configAudioResources:(NSString*)configFileName;

-(void)preloadEffect:(NSString*)namePath reduceToMono:(BOOL)flag completion:(void(^)(ALBuffer *))block;

// Play the audios in the given list simutaneously
-(void)batchPlay:(NSArray*)audioNameList;

// Asynchronizely play the specified effect, block is the play completion callback.
// The method will do nothing if slientFail = YES, meanwhile the block will NOT be called.
-(void)playEffect:(NSString*)namePath slientFail:(BOOL)slientFail completion:(dispatch_block_t)block;

-(void)stopEffect;

-(void)unloadEffect:(NSString*)namePath;

-(void)playBackgroundMusic:(NSString*)namePath loops:(NSInteger)loops;

-(void)stopBackgroundMusic;

-(void)pausedBgMusic:(BOOL)bgPaused effect:(BOOL)effPaused;

-(ListPlayManager*)stepPlayingList:(NSString*)listID;

-(void)setVolumeForBgMusic:(float)bgVolume effect:(float)eVolume;

-(void)setMutedForBgMusic:(BOOL)bgMuted effect:(BOOL)effectMuted;

@end
