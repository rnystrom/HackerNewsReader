//
//  AppDelegate.m
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 4/5/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import "AppDelegate.h"

#import "HNFeedViewController.h"
#import "HNNavigationController.h"
#import "UIToolbar+HackerNews.h"
#import "UINavigationBar+HackerNews.h"

@interface AppDelegate () <UISplitViewControllerDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [UINavigationBar enableAppearance];
    [UIToolbar enableAppearance];
    return YES;
}

@end
