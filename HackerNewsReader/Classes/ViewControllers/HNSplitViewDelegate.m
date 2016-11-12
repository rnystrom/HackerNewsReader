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

// http://stackoverflow.com/a/27965772
- (BOOL)splitViewController:(UISplitViewController *)splitViewController showDetailViewController:(UIViewController *)detailViewController sender:(id)sender {
    UITabBarController *masterViewController = splitViewController.viewControllers.firstObject;

    if (splitViewController.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact) {
        [masterViewController.selectedViewController showViewController:detailViewController sender:sender];
    } else {
        [splitViewController setViewControllers:@[masterViewController, detailViewController]];
    }

    return YES;
}

- (UIViewController*)splitViewController:(UISplitViewController *)splitViewController separateSecondaryViewControllerFromPrimaryViewController:(UIViewController *)primaryViewController {
    UITabBarController *masterVC = splitViewController.viewControllers.firstObject;

    if ([(UINavigationController*)masterVC.selectedViewController viewControllers].count > 1) {
        return [(UINavigationController*)masterVC.selectedViewController popViewControllerAnimated:NO];
    } else {
        return nil;
    }
}

@end
