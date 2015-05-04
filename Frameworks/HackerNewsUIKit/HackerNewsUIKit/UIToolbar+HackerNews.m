//
//  UIToolbar+HackerNews.m
//  HackerNewsUIKit
//
//  Created by Ryan Nystrom on 4/8/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import "UIToolbar+HackerNews.h"

#import <HackerNewsUIKit/UIColor+HackerNews.h>

@implementation UIToolbar (HackerNews)

+ (void)enableAppearance {
    id appearance = [self appearance];
    [appearance setTintColor:[UIColor brandColor]];
}

@end
