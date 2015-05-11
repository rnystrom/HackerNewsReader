//
//  UIFont+HackerNews.h
//  HackerNewsUIKit
//
//  Created by Ryan Nystrom on 4/8/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIFont (HackerNews)

+ (UIFont *)titleFont;
+ (UIFont *)subtitleFont;
+ (UIFont *)pageTitleFont;
+ (UIFont *)navigationFont;
+ (UIFont *)commentFont;
+ (UIFont *)commentLinkFont;
+ (UIFont *)commentCodeFont;
+ (UIFont *)commentItalicFont;

@end
