//
//  UIFont+HackerNews.h
//  HackerNewsUIKit
//
//  Created by Ryan Nystrom on 4/8/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface UIFont (HackerNews)

+ (UIFont *)hn_titleFont;
+ (UIFont *)hn_subtitleFont;
+ (UIFont *)hn_pageTitleFont;
+ (UIFont *)hn_navigationFont;
+ (UIFont *)hn_commentFont;
+ (UIFont *)hn_commentLinkFont;
+ (UIFont *)hn_commentCodeFont;
+ (UIFont *)hn_commentItalicFont;

@end

NS_ASSUME_NONNULL_END
