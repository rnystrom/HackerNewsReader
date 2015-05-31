//
//  UIViewController+HNComment.h
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 5/31/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

@import UIKit;

@class HNComment;

@interface UIViewController (HNComment) <UIActionSheetDelegate>

- (void)showActionSheetForComment:(HNComment *)comment;

@end
