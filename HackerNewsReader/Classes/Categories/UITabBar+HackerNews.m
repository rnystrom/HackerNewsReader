//
//  UITabBar+HackerNews.m
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 1/6/16.
//  Copyright © 2016 Ryan Nystrom. All rights reserved.
//

#import "UITabBar+HackerNews.h"

#import "UIColor+HackerNews.h"

@implementation UITabBar (HackerNews)

+ (void)hn_enableAppearance {
    id appearance = [self appearance];
    [appearance setTintColor:[UIColor hn_brandColor]];
}

@end
