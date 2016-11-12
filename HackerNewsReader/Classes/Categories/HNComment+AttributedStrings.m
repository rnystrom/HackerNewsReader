//
//  HNComment+AttributedStrings.m
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 4/12/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import "HNComment+AttributedStrings.h"

#import <objc/runtime.h>

@implementation HNComment (AttributedStrings)

- (NSAttributedString *)attributedString {
    static void *kHNCommentAttributedString = &kHNCommentAttributedString;
    NSAttributedString *attributedString = objc_getAssociatedObject(self, kHNCommentAttributedString);
    if (!attributedString) {
        attributedString = HNAttributedStringFromComponents(self.components);
        objc_setAssociatedObject(self, kHNCommentAttributedString, attributedString, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return attributedString;
}

@end
