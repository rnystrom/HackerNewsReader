//
//  AppDelegate.m
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 4/5/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import "AppDelegate.h"

#import "UIToolbar+HackerNews.h"
#import "UINavigationBar+HackerNews.h"
#import "HNUITestURLProtocol.h"

NSString * const kHNAppDelegateDidTapStatusBar = @"kHNAppDelegateDidTapStatusBar";

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [UINavigationBar enableAppearance];
    [UIToolbar enableAppearance];
    if ([launchOptions[@"ui_test"] boolValue]) {
        [NSURLProtocol registerClass:[HNUITestURLProtocol class]];
    }
    return YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];

    if ([touches count] == 1) {
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self.window];
        if (CGRectContainsPoint([UIApplication sharedApplication].statusBarFrame, point)) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kHNAppDelegateDidTapStatusBar object:self];
        }
    }
}

@end
