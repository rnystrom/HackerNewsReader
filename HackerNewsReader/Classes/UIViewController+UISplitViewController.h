//
//  UIViewController+UISplitViewController.h
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 6/1/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (hn_UISplitViewController)

- (void)hn_configureLeftButtonAsDisplay;

- (void)hn_showDetailViewControllerWithFallback:(UIViewController *)controller;

- (void)hn_dismissDetailViewControllerWithFallback:(UIViewController *)controller;

@end

NS_ASSUME_NONNULL_END
