//
//  UINavigationController+HNBarState.h
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 6/1/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (HNBarState)

- (void)setHidesBarsOnSwipe:(BOOL)hidesBarsOnSwipe navigationBarHidden:(BOOL)navigationBarHidden toolbarHidden:(BOOL)toolbarHidden animated:(BOOL)animated;

@end
