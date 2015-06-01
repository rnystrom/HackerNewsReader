//
//  UIViewController+UISplitViewController.h
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 6/1/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (hn_UISplitViewController)

- (void)configureLeftButtonAsDisplay;

- (void)showDetailViewControllerWithFallback:(UIViewController *)controller;

@end
