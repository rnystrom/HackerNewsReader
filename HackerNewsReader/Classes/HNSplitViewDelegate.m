//
//  HNSplitViewDelegate.m
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 5/31/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import "HNSplitViewDelegate.h"

NSString * const kHNSplitViewDelegateWillChangeDisplayMode = @"kHNSplitViewDelegateWillChangeDisplayMode";

@implementation HNSplitViewDelegate

- (BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController {
    return YES;
}

- (UISplitViewControllerDisplayMode)targetDisplayModeForActionInSplitViewController:(UISplitViewController *)svc {
    [[NSNotificationCenter defaultCenter] postNotificationName:kHNSplitViewDelegateWillChangeDisplayMode object:nil];
    return UISplitViewControllerDisplayModeAutomatic;
}

@end
