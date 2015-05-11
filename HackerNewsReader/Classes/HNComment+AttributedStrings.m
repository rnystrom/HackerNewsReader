//
//  HNComment+AttributedStrings.m
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 4/12/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import "HNComment+AttributedStrings.h"

@implementation HNComment (AttributedStrings)

- (NSAttributedString *)attributedString {
    return attributedStringFromComponents(self.components);
}

@end
