//
//  UIColor+HackerNews.m
//  HackerNewsUIKit
//
//  Created by Ryan Nystrom on 4/8/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import "UIColor+HackerNews.h"

#define HEX_COLOR(hexValue) \
[UIColor colorWithRed:((float)(((hexValue) & 0xFF0000) >> 16)) / 255.0 \
green:((float)(((hexValue) & 0xFF00) >> 8)) / 255.0 \
blue:((float)((hexValue) & 0xFF)) / 255.0 \
alpha:1.0]

@implementation UIColor (HackerNews)

+ (UIColor *)hn_brandColor {
    return [UIColor colorWithRed:1.0 green:0.4 blue:0.0 alpha:1.0];
}

+ (UIColor *)hn_navigationTextColor {
    return [UIColor whiteColor];
}

+ (UIColor *)hn_navigationTintColor {
    return [UIColor whiteColor];
}

+ (UIColor *)hn_subtitleTextColor {
    return [UIColor colorWithRed:189 / 255.0 green:190 / 255.0 blue:194 / 255.0 alpha:1.0];
}

+ (UIColor *)hn_titleTextColor {
    return HEX_COLOR(0x333333);
}

+ (UIColor *)hn_highlightedTintColor {
    return [UIColor colorWithWhite:0.375 alpha:1.0];
}

+ (UIColor *)hn_overlayHighlightColor {
    return [UIColor colorWithWhite:0.0 alpha:0.1];
}

@end
