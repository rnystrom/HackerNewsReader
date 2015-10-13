//
//  UIFont+HackerNews.m
//  HackerNewsUIKit
//
//  Created by Ryan Nystrom on 4/8/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import "UIFont+HackerNews.h"

@implementation UIFont (HackerNews)

+ (UIFont *)hn_titleFont {
    return [UIFont systemFontOfSize:15.0];
}

+ (UIFont *)hn_subtitleFont {
    return [UIFont systemFontOfSize:12.0];
}

+ (UIFont *)hn_pageTitleFont {
    return [UIFont boldSystemFontOfSize:17.0];
}

+ (UIFont *)hn_navigationFont {
    return [UIFont fontWithName:@"Avenir-Heavy" size:18.0];
}

+ (UIFont *)hn_commentFont {
    return [UIFont systemFontOfSize:15.0];
}

+ (UIFont *)hn_commentLinkFont {
    return [UIFont systemFontOfSize:15.0];
}

+ (UIFont *)hn_commentCodeFont {
    return [UIFont fontWithName:@"Courier" size:15.0];
}

+ (UIFont *)hn_commentItalicFont {
    return [UIFont italicSystemFontOfSize:15.0];
}

@end
