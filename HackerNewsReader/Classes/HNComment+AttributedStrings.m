//
//  HNComment+AttributedStrings.m
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 4/12/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import "HNComment+AttributedStrings.h"

#import "UIColor+HackerNews.h"
#import "UIFont+HackerNews.h"

NSString * const HNCommentLinkAttributeName = @"HNCommentLinkAttributeName";

@implementation HNComment (AttributedStrings)

- (NSAttributedString *)attributedString {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];

    for (HNCommentComponent *component in self.components) {
        NSDictionary *attributes;

        switch (component.type) {
            case HNCommentNewline:
            case HNCommentTypeCode:
                attributes = @{
                               NSFontAttributeName: [UIFont commentCodeFont],
                               NSForegroundColorAttributeName: [UIColor titleTextColor]
                               };
                break;
            case HNCommentTypeItalic:
                attributes = @{
                               NSFontAttributeName: [UIFont commentItalicFont],
                               NSForegroundColorAttributeName: [UIColor titleTextColor]
                               };
                break;
            case HNCommentTypeLink:
                attributes = @{
                               NSFontAttributeName: [UIFont commentLinkFont],
                               NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle),
                               NSForegroundColorAttributeName: [UIColor titleTextColor],
                               HNCommentLinkAttributeName: component.text ?: @""
                               };
                break;
            case HNCommentTypeText:
                attributes = @{
                               NSFontAttributeName: [UIFont commentFont],
                               NSForegroundColorAttributeName: [UIColor titleTextColor]
                               };
                break;
            case HNCommentRemoved:
                attributes = @{
                               NSFontAttributeName: [UIFont commentFont],
                               NSForegroundColorAttributeName: [UIColor subtitleTextColor]
                               };
                break;
        }

        NSString *text = component.text;
        if (component != self.components.firstObject && component.type == HNCommentNewline) {
            text = [@"\n\n" stringByAppendingString:text];
        }

        NSAttributedString *componentString = [[NSAttributedString alloc] initWithString:text attributes:attributes];
        [attributedString appendAttributedString:componentString];
    }

    return attributedString;
}

@end
