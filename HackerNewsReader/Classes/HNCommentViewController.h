//
//  HNCommentViewController.h
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 4/9/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HNPost;

@interface HNCommentViewController : UITableViewController

- (instancetype)initWithPost:(HNPost *)post;

@end
