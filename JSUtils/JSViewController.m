//
//  JSViewController.m
//  JSUtils
//
//  Created by Song Lanlan on 7/5/15.
//  Copyright (c) 2015 Song Lanlan. All rights reserved.
//

#import "JSViewController.h"

#import "TestDrawableView.h"

#import "JSExtendButton.h"

#import "TestJSSpriteLayerVC.h"

@interface JSViewController ()

@end

@implementation JSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self testJSSpriteLayer];
//    [self testDrawabeView];
//    [self testMaskingView];
//    [self testJSExtendBtn];
}

- (void)testJSSpriteLayer {
    TestJSSpriteLayerVC *vc = [TestJSSpriteLayerVC new];
    [self.view addSubview:vc.view];
}

- (void)testDrawabeView{
    TestDrawableView *view = [[TestDrawableView alloc] initWithFrame:CGRectInset(self.view.bounds, 0, 40)];
    [self.view addSubview:view];
}

- (void)testMaskingView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(50, 50, 200, 200)];
    view.backgroundColor = [UIColor yellowColor];
    
    [view jsAddMaskImage:[UIImage imageNamed:@"mask.png"]];
    
    [self.view addSubview:view];
}

- (void)testJSExtendBtn {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    btn.frame = CGRectMake(10, 10, 50, 20);
    
    [btn setTitle:@"aaaaa" forState:UIControlStateNormal];
    [btn setTitle:@"bbb" forState:UIControlStateHighlighted];
    
    [btn addTarget:self action:@selector(foo) forControlEvents:UIControlEventTouchUpInside];
    
    JSExtendButton *js = [[JSExtendButton alloc] initWithFrame:CGRectMake(50, 50, 100, 100)
                                                    origButton:btn];
    
    [btn debug];
    [js debug];
    [self.view addSubview:js];
}
- (void)foo {
    DLog(@"dgsdf");
}


@end
