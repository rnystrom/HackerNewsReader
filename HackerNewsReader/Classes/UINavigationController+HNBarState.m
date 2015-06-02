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
    if ([self respondsToSelector:@selector(setHidesBarsOnSwipe:)]) {
        self.hidesBarsOnSwipe = hidesBarsOnSwipe;
    }

    [self setNavigationBarHidden:navigationBarHidden animated:animated];
    [self setToolbarHidden:toolbarHidden animated:animated];
}

@end
