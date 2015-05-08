
#import <Foundation/Foundation.h>


@interface JSPair : NSObject

@property (nonatomic, readonly) id first;
@property (nonatomic, readonly) id second;

+ (id)pairWithFirstObject:(id)first secondObject:(id)second;
- (id)initWithFirstObject:(id)first secondObject:(id)second;

@end
