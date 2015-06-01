//
//  UINavigationController+HNBarState.m
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 6/1/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import "UINavigationController+HNBarState.h"

@implementation UINavigationController (HNBarState)

- (void)setHidesBarsOnSwipe:(BOOL)hidesBarsOnSwipe navigationBarHidden:(BOOL)navigationBarHidden toolbarHidden:(BOOL)toolbarHidden animated:(BOOL)animated {
    if ([self.navigationController respondsToSelector:@selector(setHidesBarsOnSwipe:)]) {
        self.navigationController.hidesBarsOnSwipe = hidesBarsOnSwipe;
    }

    [self.navigationController setNavigationBarHidden:navigationBarHidden animated:animated];
    [self.navigationController setToolbarHidden:toolbarHidden animated:animated];
}

@end
