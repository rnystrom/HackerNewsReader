//
//  AppDelegate.m
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 4/5/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import "AppDelegate.h"

#import "HNQueries.h"

#import <Appirater/Appirater.h>

#import "HNSession.h"

#import "UIToolbar+HackerNews.h"
#import "UITabBar+HackerNews.h"
#import "UINavigationBar+HackerNews.h"
#import "HNSessionManager.h"

NSString * const kHNAppDelegateDidTapStatusBar = @"kHNAppDelegateDidTapStatusBar";

@implementation AppDelegate

- (void)setupAppirater {
    [Appirater setAppId:@"1000995253"];
    [Appirater setDaysUntilPrompt:7];
    [Appirater setUsesUntilPrompt:5];
    [Appirater setSignificantEventsUntilPrompt:-1];
    [Appirater setTimeBeforeReminding:2];
    [Appirater setDebug:NO];
    [Appirater appLaunched:YES];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self setupAppirater];

    [HNQueries loadRemoteQueries];

    [UINavigationBar hn_enableAppearance];
    [UIToolbar hn_enableAppearance];
    [UITabBar hn_enableAppearance];

//    UISplitViewController *rootViewController = (UISplitViewController *)self.window.rootViewController;
//    UITabBarController *tabBarController = rootViewController.viewControllers.firstObject;
//    UINavigationController *profileNavigationController = tabBarController.viewControllers.lastObject;
//    HNSessionManager *sessionManager = [[HNSessionManager alloc] initWithNavigationController:profileNavigationController];
//
//    HNSession *session = [HNSession activeSession];
//    const BOOL animated = NO;
//    if (session != nil) {
//        [sessionManager transitionToLoggedInWithSession:session animated:animated];
//    } else {
//        [sessionManager transitionToLoggedOutAnimated:animated];
//    }

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
