
#import "JSPair.h"


@implementation JSPair

+ (id)pairWithFirstObject:(id)first secondObject:(id)second{
    return [[[self alloc] initWithFirstObject:first secondObject:second] autorelease];
}

- (id)initWithFirstObject:(id)first secondObject:(id)second{
    if ((self = [super init])) {
        _first = [first retain];
        _second = [second retain];
    }
    return self;
}

- (void)dealloc{
    [_first release];
    [_second release];
    [super dealloc];
}

- (NSString *)description{
    return [NSString stringWithFormat:@"%@ <%p> (firstObject = %@, secondObject = %@)", [self class], self,
            self.first, self.second];
}

@end
