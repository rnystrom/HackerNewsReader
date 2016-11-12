//
//  UIColor+HackerNews.h
//  HackerNewsUIKit
//
//  Created by Ryan Nystrom on 4/8/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (HackerNews)

+ (UIColor *)hn_brandColor;
+ (UIColor *)hn_navigationTextColor;
+ (UIColor *)hn_navigationTintColor;
+ (UIColor *)hn_subtitleTextColor;
+ (UIColor *)hn_titleTextColor;
+ (UIColor *)hn_highlightedTintColor;
+ (UIColor *)hn_overlayHighlightColor;

@end

NS_ASSUME_NONNULL_END
