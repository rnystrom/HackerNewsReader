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

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [UINavigationBar enableAppearance];
    [UIToolbar enableAppearance];
    if ([launchOptions[@"ui_test"] boolValue]) {
        [NSURLProtocol registerClass:[HNUITestURLProtocol class]];
    }
    return YES;
}

@end
