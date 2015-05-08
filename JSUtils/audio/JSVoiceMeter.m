//
//  SCRVoiceMeter.m
//  iAudition
//
//  Created by Aleks Nesterow-Rutkowski on 11/15/09.
//  aleks@screencustoms.com
//

#import "JSVoiceMeter.h"

#define CAT	@"VoiceMeter"
#define CheckIfAudioQueueError(status, message) { if (status != noErr) DLog(message); }

@interface JSVoiceMeter (/* Private Methods */)

- (void)__initializeComponent;
- (BOOL)__start;
- (void)__stop;

@end

@implementation JSVoiceMeter

#pragma mark AudioQueue input buffer

static void HandleInputBuffer(void *userData, AudioQueueRef audioQueue, AudioQueueBufferRef buffer,
							  const AudioTimeStamp *packetStartTime, UInt32 packetsCount,
							  const AudioStreamPacketDescription *packetDescription) {
	
	JSVoiceMeter *voiceMeter = (JSVoiceMeter *)userData;
	if (voiceMeter.isMeteringEnabled) {
		CheckIfAudioQueueError(AudioQueueEnqueueBuffer(voiceMeter->queue, buffer, 0, NULL), @"Cannot enqueue buffer.");
	}
}

static UInt32 DeriveBufferSize(AudioQueueRef audioQueue, const AudioStreamBasicDescription *format, Float64 seconds) {
	
	static const int maxBufferSize = 0x50000;
	UInt32 maxPacketSize = format->mBytesPerPacket;
	if (0 == maxPacketSize) {
		UInt32 maxVBRPacketSize = sizeof(maxPacketSize);
		CheckIfAudioQueueError(AudioQueueGetProperty(audioQueue, kAudioQueueProperty_MaximumOutputPacketSize
                                                     , &maxPacketSize, &maxVBRPacketSize),
							   @"Cannot get the value of the kAudioQueueProperty_MaximumOutputPacketSize property.");
	}
	
	Float64 numBytesForTime = format->mSampleRate * maxPacketSize * seconds;
	return (UInt32)(numBytesForTime < maxBufferSize ? numBytesForTime : maxBufferSize);
}

#pragma mark init / dealloc

- (id)init {
	
	if ((self = [super init])) {
		[self __initializeComponent];
	}
	
	return self;
}

- (void)__initializeComponent {
	
	format.mSampleRate = [[AVAudioSession sharedInstance] currentHardwareSampleRate];
	DLog(@"Sample rate: %f", format.mSampleRate);
	
	format.mChannelsPerFrame = [[AVAudioSession sharedInstance] currentHardwareInputNumberOfChannels];
	DLog(@"Channels: %u", (unsigned int)format.mChannelsPerFrame);
	
	format.mFormatID = kAudioFormatLinearPCM;
	format.mFormatFlags = kLinearPCMFormatFlagIsBigEndian | kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
	format.mBitsPerChannel = 16;
	format.mBytesPerPacket = format.mBytesPerFrame = format.mChannelsPerFrame * sizeof(SInt16);
	format.mFramesPerPacket = 1;
	
	channelLevels = (AudioQueueLevelMeterState *)malloc(sizeof(AudioQueueLevelMeterState) * format.mChannelsPerFrame);
	channelLevelsDataSize = sizeof(AudioQueueLevelMeterState) * format.mChannelsPerFrame;
	
	OSErr status = AudioQueueNewInput(&format, HandleInputBuffer, self, NULL, kCFRunLoopCommonModes, 0, &queue);
	CheckIfAudioQueueError(status, @"Cannot create new AudioQueue.");
	if (noErr == status) {
		DLog(@"AudioQueue created successfully.");
	}
	
	UInt32 formatSize = sizeof(format);
	CheckIfAudioQueueError(AudioQueueGetProperty(queue, kAudioQueueProperty_StreamDescription, &format, &formatSize),
						   @"Cannot get the value of the kAudioQueueProperty_StreamDescription property.");
	
	UInt32 val = 1;
	CheckIfAudioQueueError(AudioQueueSetProperty(queue, kAudioQueueProperty_EnableLevelMetering, &val, sizeof(UInt32)),
						   @"Cannot enable metering.");
	
	bufferByteSize = DeriveBufferSize(queue, &format, kSCVoiceMeterBufferForTime);
	DLog(@"bufferByteSize = %d", (unsigned int)bufferByteSize);
	
	for (NSUInteger i = 0; i < kSCVoiceMeterBufferNumber; ++i) {
		
		CheckIfAudioQueueError(AudioQueueAllocateBuffer(queue, bufferByteSize, &buffers[i]), @"Cannot allocate buffer.");
		CheckIfAudioQueueError(AudioQueueEnqueueBuffer(queue, buffers[i], 0, NULL), @"Cannot enqueue buffer.");
	}
}

- (void)dealloc {

	[self setMeteringEnabled:NO];
	CheckIfAudioQueueError(AudioQueueDispose(queue, TRUE), @"Cannot dispose AudioQueue.");
	free(channelLevels);
	
	[super dealloc];
}

#pragma mark Metering

@synthesize meteringEnabled = _meteringEnabled;
- (void)setMeteringEnabled:(BOOL)yesOrNo {
	
	if (_meteringEnabled != yesOrNo) {
		
		if (yesOrNo) {
			_meteringEnabled = [self __start];
		} else {
			_meteringEnabled = NO;
			[self __stop];
		}
	}
}

- (BOOL)__start {
	
	BOOL result = NO;
	
	AVAudioSession *audioSession = [AVAudioSession sharedInstance];
	NSError *error = nil;
	[audioSession setCategory:AVAudioSessionCategoryRecord error:&error];
	
	if (error) {
		DLog(@"Cannot apply Record category to AVAudioSession: %@ (%@)", error, error.userInfo);
	} else {
		
		error = nil;
		[[AVAudioSession sharedInstance] setActive:YES error:&error];
		
		if (error) {
			DLog(@"Cannot set AVAudioSession active.");
		} else {
			
			OSStatus status = AudioQueueStart(queue, NULL);
			CheckIfAudioQueueError(status, @"Cannot start AudioQueue.");
			
			if (noErr == status) {
				
				DLog(@"AudioQueue started successfully.");
				result = YES;
			}
		}
	}
	
	return result;
}

- (void)__stop {
	
	DLog(@"Stopping...");
	OSErr status = AudioQueueStop(queue, TRUE);
	CheckIfAudioQueueError(status, @"Cannot stop AudioQueue immediately.");
	if (noErr == status) {
		DLog(@"AudioQueue stopped successfully.");
	}
}

- (void)updateMeters {
	
	OSStatus status = AudioQueueGetProperty(queue, kAudioQueueProperty_CurrentLevelMeterDB, channelLevels
                                            , &channelLevelsDataSize);
	CheckIfAudioQueueError(status, @"Cannot get the value of the kAudioQueueProperty_CurrentLevelMeterDB property.");
}

- (float)averagePowerForChannel:(NSUInteger)channelNumber {

	return channelLevels[channelNumber].mAveragePower;
}

- (float)peakPowerForChannel:(NSUInteger)channelNumber {

	return channelLevels[channelNumber].mPeakPower;
}

@end
