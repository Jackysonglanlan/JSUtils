
#import <Foundation/Foundation.h>


@protocol PWDisplayLinkerDelegate <NSObject>
@required

/**
 The display will update - a new frame will be displayed.
 
 @param deltaTime The time difference between the frame about to be displayed and the previous frame (seconds).
 */
- (void)displayWillUpdateWithDeltaTime:(CFTimeInterval)deltaTime;

@optional

@end

/**
 A simple CADisplayLink wrapper class that calculates the time difference between the previous and current frame and informs the delegate.
 
 @note Unnecessary for more than one instance to be active at a time - typically the delegate will be a UIViewController that passes the protocol message on.
 */
@interface PWDisplayLinker : NSObject
{
    __weak id<PWDisplayLinkerDelegate> _delegate;
    
    CADisplayLink * _displayLink;
    
    BOOL _nextDeltaTimeZero;
    
    CFTimeInterval _previousTimestamp;
}

/// The delegate of the display linker object.
///
/// The delegate must conform to the PWDisplayLinkerDelegate protocol. The display linker does not retain the delegate.
@property(nonatomic, readonly, weak) id<PWDisplayLinkerDelegate> delegate;

/// The single CADisplayLink instance that the class wraps.
@property(nonatomic, readonly) CADisplayLink * displayLink;

/// YES if the next frame update should have a delta time of zero, NO otherwise.
/// Set YES if an irregular frame update period is expected on the upcoming frame.
@property(nonatomic, readwrite) BOOL nextDeltaTimeZero;

/**
 Initializes and returns a newly allocated display linker object with the specified delegate.
 @param delegate The delegate object that conforms to the PWDisplayLinkerDelegate protocol.
 @return An initialized display linker object or nil if the object couldn't be created.
 */
- (id)initWithDelegate:(id<PWDisplayLinkerDelegate>)delegate;

@end
