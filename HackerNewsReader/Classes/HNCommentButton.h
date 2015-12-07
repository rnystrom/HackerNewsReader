//
//  HNCommentButton.h
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 4/7/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface HNCommentButton : UIControl

- (void)setCommentText:(NSString *)commentText;

- (void)setCommentHidden:(BOOL)commentHidden;

@end

NS_ASSUME_NONNULL_END
