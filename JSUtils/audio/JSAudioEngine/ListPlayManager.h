//
//  ListPlayManager.h
//  Labrary
//
//  Created by jacky.song on 13-4-22.
//  Copyright (c) 2013 symbio.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ListPlayManager : NSObject

@property(nonatomic,copy) void(^didFinishPlayingBlock)(void);

// Play again after playing all audios
@property(nonatomic,assign) BOOL repeatPlaying;

- (id)initWithPlayList:(NSArray*)list;

// return the audio name that is currently playing, every invocation will cause the player move to the next audio.
-(NSString*)play;

-(void)cancel:(BOOL)forceStop;

@end
