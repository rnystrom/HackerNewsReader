//
//  UINavigationBar+HackerNews.m
//  HackerNewsUIKit
//
//  Created by Ryan Nystrom on 4/8/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import "UINavigationBar+HackerNews.h"

#import "HNNavigationController.h"
#import "UIColor+HackerNews.h"
#import "UIFont+HackerNews.h"

@implementation UINavigationBar (HackerNews)

+ (void)enableAppearance {
    id appearance = [self appearanceWhenContainedIn:HNNavigationController.class, nil];
    [appearance setTitleTextAttributes:@{
                                         NSForegroundColorAttributeName: [UIColor navigationTextColor],
                                         NSFontAttributeName: [UIFont navigationFont]
                                         }];
    [appearance setTintColor:[UIColor navigationTintColor]];
    [appearance setBarTintColor:[UIColor brandColor]];
}

@end
