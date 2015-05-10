//
//  JSEnLargeTapAreaButton.m
//  QMQZ
//
//  Created by admin on 15/2/11.
//  Copyright (c) 2015年 cmge. All rights reserved.
//

#import "JSExtendButton.h"

@implementation JSExtendButton{
    UIButton *origButton;
}

- (id)initWithFrame:(CGRect)frame origButton:(UIButton*)btn{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:btn];

        origButton = btn;
        
        [self cloneButtonEvent];
    }
    return self;
}

- (void)cloneButtonEvent {
    NSSet *targets = [origButton allTargets];

    NSArray *neededEvents = @[@(UIControlEventTouchUpInside),];
    
    [neededEvents each:^(NSNumber *event) {
        [targets each:^(id target) {
            int eventInt = [event intValue];
            NSArray *sele = [origButton actionsForTarget:target forControlEvent:eventInt];
            [sele each:^(NSString *seleStr) {
                SEL selector = NSSelectorFromString(seleStr);
                [self addTarget:target action:selector forControlEvents:eventInt];
//                [origButton removeTarget:target action:selector forControlEvents:eventInt];
            }];
        }];
    }];
        
}

-(void)setHighlighted:(BOOL)highlighted{
    [origButton setHighlighted:highlighted];
}

@end
