//
//  JSAudioEngine.m
//  Labrary
//
//  Created by jacky.song on 13-2-6.
//  Copyright (c) 2013 symbio.com. All rights reserved.
//

#import "JSAudioEngine.h"

@interface JSAudioEngine (){
  // [NamePath -> AudioName]
  NSMutableDictionary *audioResources;
  
  // [AudioFileName]
  NSMutableSet *lazyLoadResources;
  
  // [AudioFileName -> ALBuffer]
  NSMutableDictionary *buffers;
  
  // [listID -> array of item string value]
  NSDictionary *playListMap;
  
}

@end


@implementation JSAudioEngine
@synthesize effectTrack,bgTrack,delegate,isCancelled;

SYNTHESIZE_SINGLETON_FOR_CLASS(JSAudioEngine);

- (id)init{
  self = [super init];
  if (self) {
    [self initAudioEngine];
    
    audioResources = [[NSMutableDictionary alloc] init];
    buffers = [[NSMutableDictionary alloc] init];
    lazyLoadResources = [[NSMutableSet alloc] init];
    
  }
  return self;
}

-(void)initAudioEngine{
  // We'll let OALSimpleAudio deal with the device and context.
  [OALSimpleAudio sharedInstance];
  
  // Deal with interruptions for me!
  [OALAudioSession sharedInstance].handleInterruptions = YES;
  
  // We don't want ipod music to keep playing since
  // we have our own bg music.
  [OALAudioSession sharedInstance].allowIpod = NO;
  
  // Mute all audio if the silent switch is turned on.
  [OALAudioSession sharedInstance].honorSilentSwitch = YES;
  
  // Background music track.
  bgTrack = [[OALAudioTrack track] retain];
  // Effect music track.
  effectTrack = [[ALSource source] retain];
  
}

#pragma mark helper

-(ALBuffer*)cacheBuffer:(NSString*)audioName reduceToMono:(BOOL)flag{
  ALBuffer* buffer = [[OpenALManager sharedInstance] bufferFromFile:audioName reduceToMono:flag];
  if (buffer) {
    buffers[audioName] = buffer;
  }
  return buffer;
}

#pragma mark AudioResources

-(NSString*)audioFileForName:(NSString*)namePath reportMissingFile:(BOOL)reportFail{
  NSString *audio = [audioResources valueForKeyPath:namePath];
  if (audio) return audio;
  
  if (!reportFail) return nil;
  
  JS_Stub_Throw(@"Wrong NamePath", @"Can't find value for name path: %@",namePath);
}

-(void)processAudioResources:(NSDictionary*)configData prefix:(NSString*)prefix{
  for (NSString *key in [configData allKeys]) {
    id item = configData[key];
    
    Class type = [item class];
    if ([type isSubclassOfClass:NSDictionary.class] || [type isSubclassOfClass:NSArray.class]) {
      NSString *origPrefix = prefix;
      prefix = [prefix stringByAppendingFormat:@"%@.",key];
      
      // recursive parse
      [self processAudioResources:item prefix:prefix];
      
      // reverse prefix
      prefix = origPrefix;
    }
    else if ([type isSubclassOfClass:NSString.class]){
      NSString *fullKeyPath = [prefix stringByAppendingFormat:@"%@",key];
      
      // format: audioName_Preload, audioName_Lazyload
      NSString *lowwer = [key lowercaseString];
      if ([lowwer endsWith:@"_preload"] || [lowwer endsWith:@"_lazyload"]) {
        NSString *audioFile = item;
        NSArray *tmp = [key componentsSeparatedByString:@"_"];
        
        // those need preload
        if ([lowwer endsWith:@"_preload"]) {
          // cache now
          [self cacheBuffer:audioFile reduceToMono:NO];
        }
        
        // those need lazyload
        else if ([lowwer endsWith:@"_lazyload"]) {
          
          // record
          [lazyLoadResources addObject:audioFile];
        }
        
        // all must be reversed to original key for use, tmp[0] is the original name
        fullKeyPath = [prefix stringByAppendingFormat:@"%@",tmp[0]];
      }
      
      // save it to audioResources
      [audioResources jsSetObject:item forKeyPath:fullKeyPath];
    }
  }
}

#pragma mark play list

-(void)processPlayList:(NSDictionary*)configData{
  playListMap = [configData retain];
}

#pragma mark public

-(void)releaseResources{
  //    JS_releaseSafely(bgTrack);
  //    JS_releaseSafely(effectTrack);
  [buffers removeAllObjects];
  [effectTrack unregisterAllNotifications];
  [effectTrack clear];
  [bgTrack clear];
  [[OpenALManager sharedInstance] clearAllBuffers];
}

-(void)configAudioResources:(NSString*)configFileName{
  NSString *path = [[NSBundle mainBundle] pathForResource:configFileName ofType:@"plist"];
  NSDictionary *resources = [NSDictionary dictionaryWithContentsOfFile:path];
  if (!resources) {
    JS_Stub_Throw(@"Fatal Error", @"%@ file NOT FOUND",configFileName);
  }
  
  [self processAudioResources:resources[@"AudioResources"] prefix:@""];
  
  [self processPlayList:resources[@"PlayList"]];
  
  //    [resources log];
  //    [audioResources log];
  //    [lazyLoadResources log];
}

-(void)preloadEffect:(NSString*)namePath reduceToMono:(BOOL)flag completion:(void(^)(ALBuffer *))block{
  [Executors dispatchAsync:DISPATCH_QUEUE_PRIORITY_DEFAULT task:^{
    NSString *audio = [self audioFileForName:namePath reportMissingFile:YES];
    ALBuffer *buffer = [self cacheBuffer:audio reduceToMono:flag];
    if (block) block(buffer);
  }];
}

-(void)batchPlay:(NSArray*)audios{
  OALSimpleAudio *player = [OALSimpleAudio sharedInstance];
  for (NSString *namePath in audios) {
    NSString *audio = [self audioFileForName:namePath reportMissingFile:YES];
    [player playEffect:audio];
  }
}

-(void)playEffect:(NSString*)namePath slientFail:(BOOL)slientFail completion:(dispatch_block_t)block{
  NSString *audio = [self audioFileForName:namePath reportMissingFile:!slientFail];
  if (!audio) return;
  
  ALBuffer *buffer = buffers[audio];
  if (!buffer) {
    buffer = [[OpenALManager sharedInstance] bufferFromFile:audio];
    // implement "lazyload" feature
    if (buffer && [lazyLoadResources containsObject:audio]) {
      buffers[audio] = buffer;
      [lazyLoadResources removeObject:audio];
    }
  }
  if (block) {
    // register completion callback
    [effectTrack registerNotification:AL_BUFFERS_PROCESSED
                             callback:^(ALSource *source, ALuint notificationID, ALvoid *userData) {
                               block();
                             }
                             userData:nil];
  }
  // this is a asynchronize call, in another thread, so the "play thread" will not be blocked.
  [effectTrack play:buffer];
}

-(void)stopEffect{
  [effectTrack stop];
}

-(void)unloadEffect:(NSString*)namePath{
  NSString *audio = [self audioFileForName:namePath reportMissingFile:YES];
  [buffers removeObjectForKey:audio];
}

-(void)playBackgroundMusic:(NSString*)namePath loops:(NSInteger)loops{
  NSString *audio = [self audioFileForName:namePath reportMissingFile:YES];
  [bgTrack playFile:audio loops:loops];
}

-(void)stopBackgroundMusic{
  [bgTrack stop];
}

-(void)pausedBgMusic:(BOOL)bgPaused effect:(BOOL)effPaused{
  bgTrack.paused = bgPaused;
  effectTrack.paused = effPaused;
}

-(ListPlayManager*)stepPlayingList:(NSString*)listID{
  NSArray *list = playListMap[listID];
  return [[[ListPlayManager alloc] initWithPlayList:list] autorelease];
}

-(void)setVolumeForBgMusic:(float)bgVolume effect:(float)eVolume{
  bgTrack.volume = bgVolume;
  effectTrack.volume = eVolume;
}

-(void)setMutedForBgMusic:(BOOL)bgMuted effect:(BOOL)effectMuted{
  bgTrack.muted = bgMuted;
  effectTrack.muted = effectMuted;
}

@end
