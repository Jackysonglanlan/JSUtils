//
//  RACTests.m
//  Test
//
//  Created by admin on 15/1/6.
//  Copyright (c) 2015年 jackysong. All rights reserved.
//

#import "AbstractTests.h"

#import "ReactiveCocoa.h"

@interface RACFoo : NSObject
@property(nonatomic,retain) NSString *pwd;
@property(nonatomic,retain) NSString *pwdConfirmed;
@property(nonatomic,assign) BOOL createEnabled;

@property(nonatomic,retain) UIImage *img;

@end

@implementation RACFoo

-(void)setImg:(UIImage *)img{
    NSLog(@"Image %@ setted.. By main thread ? %d.",img, [[NSThread currentThread] isMainThread]);
}

@end

@interface RACTests : AbstractTests
@end

@implementation RACTests

#pragma mark helpers

-(RACSignal*)asyncOperationWithReturn:(id)retValue {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [NSThread sleepForTimeInterval:1];
            [subscriber sendNext:retValue];
            [subscriber sendCompleted];
        });
        return nil;
    }];
}

#pragma mark tests

// The -switchToLatest operator is applied to a signal-of-signals, and always forwards the values from the latest signal:
- (void)testSwitch {
    RACSubject *letters = [RACSubject subject];
    RACSubject *numbers = [RACSubject subject];
    RACSubject *signalOfSignals = [RACSubject subject];
    
    RACSignal *switched = [signalOfSignals switchToLatest];
    
    // Outputs: A B 1 D
    [switched subscribeNext:^(NSString *x) {
        NSLog(@"%@", x);
    }];
    
    [signalOfSignals sendNext:letters];// now only values sent by letters can be received.
    [letters sendNext:@"A"];
    [letters sendNext:@"B"];
    
    [signalOfSignals sendNext:numbers];// now only values sent by numbers can be received.
    [letters sendNext:@"C"];// this is sent by letters, so can't be received.
    [numbers sendNext:@"1"];
    
    [signalOfSignals sendNext:letters];// now only values sent by letters can be received.
    [numbers sendNext:@"2"];// this is sent by numbers, so can't be received.
    [letters sendNext:@"D"];
}

- (void)testCombineLatest {
    RACSubject *letters = [RACSubject subject];
    RACSubject *numbers = [RACSubject subject];
    RACSignal *combined = [RACSignal
                           combineLatest:@[ letters, numbers ]
                           reduce:^(NSString *letter, NSString *number) {
                               return [letter stringByAppendingString:number];
                           }];
    
    // Outputs: B1 B2 C2 C3
    [combined subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    
    [letters sendNext:@"A"];
    [letters sendNext:@"B"];// letters first set
    [numbers sendNext:@"1"];// numbers first set, combined will get a signal
    [numbers sendNext:@"2"];
    [letters sendNext:@"C"];
    [numbers sendNext:@"3"];
    
    // Note that the combined signal will only send its first value when all of the inputs have sent at least one.
    // In the example above, @"A" was never forwarded because numbers had not sent a value yet.
}

// -then: starts the original signal, waits for it to complete, and then only forwards the values from a new signal:
- (void)testThen {
    RACSignal *letters = [@"A B C D E F G H I" componentsSeparatedByString:@" "].rac_sequence.signal;
    
    // The new signal only contains: 1 2 3 4 5 6 7 8 9
    //
    // But when subscribed to, it also outputs: A B C D E F G H I
    RACSignal *sequenced = [[letters
                             doNext:^(NSString *letter) {
                                 NSLog(@"subscribeNext callback: %@", letter);
                             }]
                            then:^{
                                return [@"1 2 3 4 5 6 7 8 9" componentsSeparatedByString:@" "].rac_sequence.signal;
                            }];
    
    [sequenced subscribeNext:^(id x) {
        NSLog(@"subscribeNext new: %@",x);
    }
                   completed:^{
                       NSLog(@"Done");
                       [self finishedAsyncOperation];
                   }];
    
    [self beginAsyncOperationWithTimeout:1];
}

// The +merge: method will forward the values from many signals into a single stream, as soon as those values arrive:
- (void)testMerge {
    RACSubject *letters = [RACSubject subject];
    RACSubject *numbers = [RACSubject subject];
    RACSignal *merged = [RACSignal merge:@[ letters, numbers ]];
    
    // Outputs: A 1 B C 2
    [merged subscribeNext:^(NSString *x) {
        NSLog(@"%@", x);
    }];
    
    [letters sendNext:@"A"];
    [numbers sendNext:@"1"];
    [letters sendNext:@"B"];
    [letters sendNext:@"C"];
    [numbers sendNext:@"2"];
}

// The -flatten operator is applied to a stream-of-streams, and combines their values into a single new stream.
- (void)testFlatten {
    RACSubject *letters = [RACSubject subject];
    RACSubject *numbers = [RACSubject subject];
    RACSignal *signalOfSignals = [RACSignal createSignal:^ RACDisposable * (id<RACSubscriber> subscriber) {
        [subscriber sendNext:letters];
        [subscriber sendNext:numbers];
        [subscriber sendCompleted];
        return nil;
    }];
    
    RACSignal *flattened = [signalOfSignals flatten];
    // it flattens the "letters" and "numbers", so it can receive *all* values that send by those RACSubject.
    
    // Outputs: A 1 B C 2
    [flattened subscribeNext:^(NSString *x) {
        NSLog(@"%@", x); // Both "letters" and "numbers" values can be got right here
    }];
    
    [letters sendNext:@"A"];
    [numbers sendNext:@"1"];
    [letters sendNext:@"B"];
    [letters sendNext:@"C"];
    [numbers sendNext:@"2"];
    
}

- (void)testFlattenMap {
    RACSequence *numbers = [@"1 2 3 4 5 6 7 8 9" componentsSeparatedByString:@" "].rac_sequence;
    
    // Contains: 1 1 2 2 3 3 4 4 5 5 6 6 7 7 8 8 9 9
    RACSequence *extended = [numbers flattenMap:^(NSString *num) {
        return @[ num, num ].rac_sequence;
        // every element is an array, but return value is one-dimension array, that's "flatten"
        // the element is changed, that's "map"
    }];
    
    NSLog(@"%@", extended.array);

    // so, flattenMap is " -map: followed by -flatten."
    
    // Contains: 1_ 3_ 5_ 7_ 9_
    RACSequence *edited = [numbers flattenMap:^(NSString *num) {
        if (num.intValue % 2 == 0) {
            return [RACSequence empty];
        } else {
            NSString *newNum = [num stringByAppendingString:@"_"];
            return [RACSequence return:newNum];
        }
    }];
    
    NSLog(@"%@", edited.array);
}

- (void)testJoinSignals {
    RACSignal *helloWorld = [RACSignal createSignal:^RACDisposable* (id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"Hello, "];
        [subscriber sendNext:@"world!"];
        [subscriber sendCompleted];
        return nil;
    }];
    
    RACSignal *joiner = [RACSignal createSignal:^RACDisposable* (id<RACSubscriber> subscriber) {
        NSMutableArray *strings = [NSMutableArray array];
        return [helloWorld subscribeNext:^(NSString *x) {
            [strings addObject:x];
        } error:^(NSError *error) {
            [subscriber sendError:error];
        } completed:^{
            [subscriber sendNext:[strings componentsJoinedByString:@""]];
            [subscriber sendCompleted];
        }];
    }];
    
    [joiner subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }
                completed:^{
        NSLog(@"Done");
    }];
}

- (void)testChainAsynOperations {
    [[[[[self asyncOperationWithReturn:@1]
     flattenMap:^RACStream *(id value) {
         NSLog(@"1 %@",value);
         NSNumber *num = value;
         return [self asyncOperationWithReturn:@(num.intValue + 1) ];
     }]
     flattenMap:^RACStream *(id value) {
         NSLog(@"2 %@",value);
         NSNumber *num = value;
         return [self asyncOperationWithReturn:@(num.intValue + 1) ];
      }]
     flattenMap:^RACStream *(id value) {
         NSLog(@"3 %@",value);
         NSNumber *num = value;
         return [self asyncOperationWithReturn:@(num.intValue + 1) ];
      }]
     subscribeNext:^(id x) {
         NSLog(@"subscribe next: %@",x);
      } completed:^{
         NSLog(@"Done");
         [self finishedAsyncOperation];
      }];
    
    [self beginAsyncOperationWithTimeout:30];
}

- (void)testAsyncOperation {
    RACFoo *f = [RACFoo new];
    
    RAC(f, img) = [[[[self asyncOperationWithReturn:@123 ] deliverOn:[RACScheduler scheduler]]
                    map:^id(NSNumber *userId) {
                        NSLog(@"id from signal %@",userId);
                        return [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://www.baidu.com/img/bd_logo1.png"]]];
                        
                    }]
                   deliverOn:[RACScheduler mainThreadScheduler]];
    
    [self beginAsyncOperationWithTimeout:10];
}

- (void)testBinding {
    RACFoo *f = [RACFoo new];
    
    RAC(f, createEnabled) = [RACSignal
                             combineLatest:@[RACObserve(f, pwd), RACObserve(f, pwdConfirmed)]
                             reduce:^(NSString *pwd, NSString *confirmedPwd){
                                 return @([pwd isEqualToString:confirmedPwd]);
                             }];
    
    f.pwd = @"aaa";
    f.pwdConfirmed = @"aaa";
    
    NSLog(@"%d",f.createEnabled);
}

- (void)testExample{
    NSArray *strings = @[@"aaa",@"b",@"cc"];
    RACSequence *results = [[strings.rac_sequence
                             filter:^ BOOL (NSString *str) {
                                 return str.length >= 2;
                             }]
                            map:^(NSString *str) {
                                return [str stringByAppendingString:@"foobar"];
                            }];
    
    NSLog(@"%@",results.array);
}

@end
