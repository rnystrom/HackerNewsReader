//
//  HNSearchPostsController.m
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 6/6/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import "HNSearchPostsController.h"

#import "HNFeedDataSource.h"
#import "HNPostCell.h"

@interface HNSearchPostsController ()
<UISearchResultsUpdating, HNPostCellDelegate>

@property (nonatomic, strong) HNFeedDataSource *feedDataSource;
@property (nonatomic, strong, readonly) UISearchController *searchController;

@end

@implementation HNSearchPostsController

- (instancetype)init {
    if (self = [super init]) {
        _searchController = [[UISearchController alloc] initWithSearchResultsController:self];
        _searchController.searchResultsUpdater = self;
        [_searchController.searchBar sizeToFit];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.feedDataSource = [[HNFeedDataSource alloc] initWithTableView:self.tableView readPostStore:nil];
}


#pragma mark - Public API

- (UISearchBar *)searchBar {
    return self.searchController.searchBar;
}


#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title CONTAINS[cd] %@", [self searchBar].text.lowercaseString];
    self.feedDataSource.posts = [self.posts filteredArrayUsingPredicate:predicate];
    [self.tableView reloadData];
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
    [self.delegate searchPostsController:self didSelectPost:self.feedDataSource.posts[indexPath.row]];
}


#pragma mark - HNPostCellDelegate

- (void)postCellDidTapCommentButton:(HNPostCell *)postCell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:postCell];
    [self.delegate searchPostsController:self didSelectPostComment:self.feedDataSource.posts[indexPath.row]];
}

@end
