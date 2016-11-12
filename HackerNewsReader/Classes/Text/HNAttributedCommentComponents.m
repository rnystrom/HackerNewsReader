//
//  AttributedCommentComponents.m
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 5/8/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import "HNAttributedCommentComponents.h"

#import "HNCommentComponent.h"

#import "UIColor+HackerNews.h"
#import "UIFont+HackerNews.h"

NSString * const HNCommentLinkAttributeName = @"HNCommentLinkAttributeName";

NSAttributedString *HNAttributedStringFromComponents(NSArray *components) {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];

    for (HNCommentComponent *component in components) {
        NSDictionary *attributes;

        switch (component.type) {
            case HNCommentNewline:
            case HNCommentTypeCode:
                attributes = @{
                               NSFontAttributeName: [UIFont hn_commentCodeFont],
                               NSForegroundColorAttributeName: [UIColor hn_titleTextColor]
                               };
                break;
            case HNCommentTypeItalic:
                attributes = @{
                               NSFontAttributeName: [UIFont hn_commentItalicFont],
                               NSForegroundColorAttributeName: [UIColor hn_titleTextColor]
                               };
                break;
            case HNCommentTypeLink:
                attributes = @{
                               NSFontAttributeName: [UIFont hn_commentLinkFont],
                               NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle),
                               NSForegroundColorAttributeName: [UIColor hn_titleTextColor],
                               HNCommentLinkAttributeName: component.text ?: @""
                               };
                break;
            case HNCommentTypeText:
                attributes = @{
                               NSFontAttributeName: [UIFont hn_commentFont],
                               NSForegroundColorAttributeName: [UIColor hn_titleTextColor]
                               };
                break;
            case HNCommentRemoved:
                attributes = @{
                               NSFontAttributeName: [UIFont hn_commentFont],
                               NSForegroundColorAttributeName: [UIColor hn_subtitleTextColor]
                               };
                break;
        }

        NSString *text = component.text;
        if (component != components.firstObject && component.type == HNCommentNewline) {
            text = [@"\n\n" stringByAppendingString:text];
        }

        NSAttributedString *componentString = [[NSAttributedString alloc] initWithString:text attributes:attributes];
        [attributedString appendAttributedString:componentString];
    }

    return attributedString;
}
