//
//  UIViewController+HNComment.h
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 5/31/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@class HNComment;

@interface UIViewController (HNComment)

- (void)showActionSheetForComment:(HNComment *)comment fromView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
