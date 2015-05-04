//
//  UIToolbar+HackerNews.m
//  HackerNewsUIKit
//
//  Created by Ryan Nystrom on 4/8/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import "UIToolbar+HackerNews.h"

#import "HNNavigationController.h"
#import "UIColor+HackerNews.h"

@implementation UIToolbar (HackerNews)

+ (void)enableAppearance {
    id appearance = [self appearanceWhenContainedIn:HNNavigationController.class, nil];
    [appearance setTintColor:[UIColor brandColor]];
}

@end
