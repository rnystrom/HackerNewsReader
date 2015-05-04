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

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];

    HNFeedViewController *feedController = [[HNFeedViewController alloc] init];
    HNNavigationController *navigationController = [[HNNavigationController alloc] initWithRootViewController:feedController];
    self.window.rootViewController = navigationController;

    [self.window makeKeyAndVisible];

    [UINavigationBar enableAppearance];
    [UIToolbar enableAppearance];

    return YES;
}

@end
