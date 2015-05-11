//
//  UIFont+HackerNews.m
//  HackerNewsUIKit
//
//  Created by Ryan Nystrom on 4/8/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import "UIFont+HackerNews.h"

@implementation UIFont (HackerNews)

+ (UIFont *)titleFont {
    return [UIFont systemFontOfSize:15.0];
}

+ (UIFont *)subtitleFont {
    return [UIFont systemFontOfSize:12.0];
}

+ (UIFont *)pageTitleFont {
    return [UIFont boldSystemFontOfSize:17.0];
}

+ (UIFont *)navigationFont {
    return [UIFont fontWithName:@"Avenir-Heavy" size:18.0];
}

+ (UIFont *)commentFont {
    return [UIFont systemFontOfSize:15.0];
}

+ (UIFont *)commentLinkFont {
    return [UIFont systemFontOfSize:15.0];
}

+ (UIFont *)commentCodeFont {
    return [UIFont fontWithName:@"Courier" size:15.0];
}

+ (UIFont *)commentItalicFont {
    return [UIFont italicSystemFontOfSize:15.0];
}

@end
