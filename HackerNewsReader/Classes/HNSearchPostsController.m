//
//  HNSearchPostsController.m
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 6/6/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import "HNSearchPostsController.h"

#import <HackerNewsKit/HNPost.h>

#import "HNFeedDataSource.h"
#import "HNPostCell.h"
#import "HNReadPostStore.h"
#import "HNPostControllerHandling.h"
#import "UIViewController+UISplitViewController.h"
#import "HNCommentViewController.h"

@interface HNSearchPostsController ()
<UISearchDisplayDelegate, UITableViewDataSource, UITableViewDelegate, HNPostCellDelegate>

@property (nonatomic, strong) HNFeedDataSource *feedDataSource;
@property (nonatomic, strong) HNReadPostStore *readPostStore;

@end

@implementation HNSearchPostsController

- (instancetype)initWithContentsController:(UIViewController *)viewController
                             readPostStore:(HNReadPostStore *)readPostStore {
    UISearchBar *searchBar = [[UISearchBar alloc] init];
    [searchBar sizeToFit];
    if (self = [super initWithSearchBar:searchBar contentsController:viewController]) {
        self.delegate = self;
        self.searchResultsTableView.delegate = self;
        self.searchResultsTableView.dataSource = self;
        _readPostStore = readPostStore;
    }
    return self;
}


#pragma mark - Actions

- (void)didSelectPostAtIndexPath:(NSIndexPath *)indexPath {
    HNPost *post = self.feedDataSource.posts[indexPath.row];
    [self.readPostStore readPK:post.pk];
    [self.searchResultsTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];

    UIViewController *controller = viewControllerForPost(post);
    [self.searchContentsController hn_showDetailViewControllerWithFallback:controller];
}

- (void)didSelectPostCommentAtIndexPath:(NSIndexPath *)indexPath {
    HNPost *post = self.feedDataSource.posts[indexPath.row];
    HNCommentViewController *commentController = [[HNCommentViewController alloc] initWithPostID:post.pk];
    [self.searchContentsController hn_showDetailViewControllerWithFallback:commentController];
}


#pragma mark - UISearchDisplayDelegate

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView {
    self.feedDataSource = [[HNFeedDataSource alloc] initWithTableView:tableView readPostStore:nil];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title CONTAINS[cd] %@", [self searchBar].text.lowercaseString];
    self.feedDataSource.posts = [self.posts filteredArrayUsingPredicate:predicate];
    return YES;
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.feedDataSource.posts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HNPostCell *cell = [self.feedDataSource cellForPostAtIndexPath:indexPath];
    cell.delegate = self;
    return cell;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.feedDataSource heightForPostAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self didSelectPostAtIndexPath:indexPath];
}


#pragma mark - HNPostCellDelegate

- (void)postCellDidTapCommentButton:(HNPostCell *)postCell {
    NSIndexPath *indexPath = [self.searchResultsTableView indexPathForCell:postCell];
    [self didSelectPostCommentAtIndexPath:indexPath];
}

@end
