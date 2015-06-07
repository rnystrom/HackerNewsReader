//
//  HNSearchPostsController.h
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 6/6/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

@import UIKit;

@class HNPost, HNSearchPostsController;

@protocol HNSearchPostsControllerDelegate <NSObject>

- (void)searchPostsController:(HNSearchPostsController *)searchPostsController didSelectPost:(HNPost *)post;
- (void)searchPostsController:(HNSearchPostsController *)searchPostsController didSelectPostComment:(HNPost *)post;

@end

@interface HNSearchPostsController : UITableViewController

@property (nonatomic, copy) NSArray *posts;
@property (nonatomic, weak) id <HNSearchPostsControllerDelegate> delegate;

- (UISearchBar *)searchBar;

@end
