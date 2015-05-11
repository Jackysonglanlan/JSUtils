

#import "PWDisplayLinker.h"

/**
 * 
 The binding of NSTimer to CADisplayLink, and NSTimer in different places:
 1, Different principles
 CADisplayLink is a can let us and the screen refresh rate synchronous frequency specific content to the screen timer class. CADisplayLink in a specific mode is registered to the runloop, when the screen display refresh end, runloop will send selector message CADisplayLink the specified target a specified, the CADisplayLink class corresponding to the selector will be called a.
 
 NSTimer with the specified pattern is registered to the runloop, when the cycle time arrives, runloop will provide selector message to send the target a specified.
 2, Cycle settings in different ways
 IOS device screen refresh rate (FPS) is 60Hz, So the CADisplayLink selector default call cycle is 60 times per second, This cycle can be obtained by setting the frameInterval property, The number of selector calls per second =60 CADisplayLink/frameInterval. For example, when the frameInterval is set to 2, the call will become 30 times per second. Therefore, CADisplayLink cycle is set slightly inconvenient.
 NSTimer selector call cycle can be set directly in the initialization, relatively more flexible.
 3, Different accuracy
 IOS device screen refresh rate is fixed, the CADisplayLink every time you refresh the end is called under normal circumstances, precision is high.
 The accuracy of NSTimer is lower, such as the NSTimer trigger time to time, if runloop is busy with other calls, triggering time will be postponed to the next runloop cycle. What is more, in the OS X v10.9 in order to avoid as far as possible in the NSTimer trigger time arrived to interrupt the current processing tasks, NSTimer adds the tolerance attribute, so that users can set can tolerate the trigger time range.
 4, The use of occasions
 The principle is not difficult to see, CADisplayLink uses the relative specific occasions, don't stop to redraw the suitable interface, such as video playback needs constantly to obtain the next frame for interface rendering.
 The use of NSTimer range is more extensive than the various needs, single or cyclic timing processing tasks can be used.
 
 ///////////////
 
 The following incomplete lists some important properties of CADisplayLink:
 1, frameInterval
 Read / write the NSInteger value identifies how many frames, interval selector method is invoked once, the default value is 1, which are called once per frame. Stressed that the official documents, when the value is set to less than 1, the result is unpredictable.
 
 2, duration
 Read only CFTimeInterval value, say two times the screen refresh interval between. Of note, the target attribute in the selector was the first call before being assigned. Call the interval selector is calculated by: =duration×frameInterval.
 
 The existing iOS equipment screen of FPS is 60Hz, which can be seen from the duration property of CADisplayLink. The value of duration is 0.166666... 1, i.e./60. In spite of this, We are not sure Apple does not change FPS, If a later day raised FPS to do 120Hz? Then, You set the frameInterval property value is 2 per second refresh 30 times expected, They found 60 times per second refresh, Results one can imagine, For security reasons, Or to judge by duration screen FPS to use CADisplayLink.
 3, timestamp
 Read only CFTimeInterval value, said screen displays a frame time stamp, this property is often used by target to calculate should be shown in the next frame content.
 Print timestamp value, its style is similar to the:
 
 179699.631584
 
 Although the name is time stamp, but this and the common UNIX time stamp difference is very big, in fact this is the use of CoreAnimation time format. Each CALayer has a local time (the specific role of CALayer local time will be explained in the next paper), can obtain the current local time in CALayer and print:
 
 CFTimeInterval localLayerTime = [myLayer convertTime:CACurrentMediaTime() fromLayer:nil];
 NSLog("localLayerTime:%f",localLayerTime);
 
 ///////////////

 IOS does not guarantee to invoke the callback method in the frequency of 60 times per second, depending on the:
 1, Free CPU
 If CPU is busy with other computation, can not guarantee to 60HZ execution screen rendering action, leading to skip some calls the callback method opportunity, skip the number depends CPU how busy the.
 2, The callback method of time
 If the time interval is greater than the redraw callback time per frame, will lead to skip callback calls several times, depending on the length of execution time.
 */

@implementation PWDisplayLinker
@synthesize delegate = _delegate;
@synthesize displayLink = _displayLink;
@synthesize nextDeltaTimeZero = _nextDeltaTimeZero;

- (id)initWithDelegate:(id<PWDisplayLinkerDelegate>)delegate {
    self = [super init];
    if(self) {
        _delegate = delegate;
        
        _displayLink = nil;
        
        _nextDeltaTimeZero = YES;
        
        _previousTimestamp = 0.0;
        
        [self ensureDisplayLinkIsOnRunLoop];
    }
    
    return self;
}

- (void)dealloc {
    [self ensureDisplayLinkIsRemovedFromRunLoop];
}


// Ensures the display link is initialised and on the run loop.
- (void)ensureDisplayLinkIsOnRunLoop {
    if (_displayLink) return;
    
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkUpdated)];
    
    // 'forMode:NSDefaultRunLoopMode' does not include scrollview scrolling mode, so use 'forMode:NSRunLoopCommonModes' instead
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    
    _nextDeltaTimeZero = YES;
    
    // get notified if the application active state changes
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(irregularFrameRateExpected) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(irregularFrameRateExpected) name:UIApplicationWillResignActiveNotification object:nil];
}

// Ensures the display link reference is removed and is taken off the run loop.
- (void)ensureDisplayLinkIsRemovedFromRunLoop {
    if(!_displayLink) return;
    
    [_displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    _displayLink = nil;
    _nextDeltaTimeZero = YES;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// an irregular frame rate is expected
- (void)irregularFrameRateExpected {
    [self setNextDeltaTimeZero:YES];
}


// target selector of the CADisplayLink
- (void)displayLinkUpdated {
    CFTimeInterval currentTime = [_displayLink timestamp];
    
    // calculate delta time
    CFTimeInterval deltaTime;
    if(_nextDeltaTimeZero) {
        _nextDeltaTimeZero = NO;
        
        deltaTime = 0.0;
    } else {
        deltaTime = currentTime - _previousTimestamp;
    }
    
    // store the timestamp
    _previousTimestamp = currentTime;
    
    // inform the delegate
    [_delegate displayWillUpdateWithDeltaTime:deltaTime];
}




@end
