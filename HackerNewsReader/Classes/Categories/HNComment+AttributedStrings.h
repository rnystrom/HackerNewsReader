//
//  HNComment+AttributedStrings.h
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 4/12/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

@import Foundation;

#import "HNComment.h"

#import "HNAttributedCommentComponents.h"

NS_ASSUME_NONNULL_BEGIN

@interface HNComment (AttributedStrings)

- (NSAttributedString *)attributedString;

@end

NS_ASSUME_NONNULL_END
