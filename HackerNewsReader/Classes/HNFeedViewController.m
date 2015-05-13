//
//  HNFeedViewController.m
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 4/5/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import "HNFeedViewController.h"

#import <HackerNewsNetworker/HNDataCoordinator.h>
#import <HackerNewsNetworker/HNFeedParser.h>

#import <HackerNewsKit/HNFeed.h>
#import <HackerNewsKit/HNPost.h>

#import "HNPostCell.h"
#import "HNWebViewController.h"
#import "HNEmptyTableCell.h"
#import "HNLoadingCell.h"
#import "HNCommentViewController.h"
#import "NSURL+HackerNews.h"
#import "UITableView+DataDiffing.h"

typedef NS_ENUM(NSUInteger, HNFeedViewControllerSection) {
    HNFeedViewControllerSectionData,
    HNFeedViewControllerSectionCount,
    HNFeedViewControllerSectionEmpty,
    HNFeedViewControllerSectionLoading
};

static NSString * const kPostCellIdentifier = @"kPostCellIdentifier";
static NSString * const kEmptyCellIdentifier = @"kEmptyCellIdentifier";
static NSString * const kLoadingCellIdentifier = @"kLoadingCellIdentifier";

@interface HNFeedViewController () <HNDataCoordinatorDelegate, HNPostCellDelegate>

@property (nonatomic, strong) HNDataCoordinator *dataCoordinator;
@property (nonatomic, copy) HNFeed *feed;
@property (nonatomic, strong) HNPostCell *prototypeCell;
@property (nonatomic, strong) NSMutableIndexSet *readPostIDs;

@end

@implementation HNFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Hacker News", @"The name of the Hacker News website");

    self.readPostIDs = [[NSMutableIndexSet alloc] init];

    HNFeedParser *parser = [[HNFeedParser alloc] init];
    NSString *cacheName = @"latest.feed";
    self.dataCoordinator = [[HNDataCoordinator alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue() path:@"news" parser:parser cacheName:cacheName];
    [self.dataCoordinator fetch];

    [self.tableView registerClass:HNPostCell.class forCellReuseIdentifier:kPostCellIdentifier];
    [self.tableView registerClass:HNEmptyTableCell.class forCellReuseIdentifier:kEmptyCellIdentifier];
    [self.tableView registerClass:HNLoadingCell.class forCellReuseIdentifier:kLoadingCellIdentifier];
    self.tableView.tableFooterView = [[UIView alloc] init];

    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(onRefresh:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;

    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if ([self.navigationController respondsToSelector:@selector(setHidesBarsOnSwipe:)]) {
        self.navigationController.hidesBarsOnSwipe = NO;
    }

    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self.navigationController setToolbarHidden:YES animated:animated];

    if ([self.dataCoordinator isFetching]) {
        [self.tableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];
        [self.refreshControl beginRefreshing];
    }
}


#pragma mark - Sizing

- (HNPostCell *)prototypeCell {
    if (!_prototypeCell) {
        _prototypeCell = [self.tableView dequeueReusableCellWithIdentifier:kPostCellIdentifier];
    }
    return _prototypeCell;
}


#pragma mark - Config

- (void)configureCell:(HNPostCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    HNPost *post = self.feed.items[indexPath.row];
    cell.titleLabel.text = post.title;
    NSString *detailText = [NSString stringWithFormat:NSLocalizedString(@"%zi points", @"Formatted string for the number of points"),post.score];
    if (post.URL.host.length) {
        detailText = [detailText stringByAppendingFormat:@" (%@)",post.URL.host];
    }
    cell.read = [self.readPostIDs containsIndex:post.pk];
    cell.subtitleLabel.text = detailText;
    [cell setCommentCount:post.commentCount];
    cell.delegate = self;
}

- (void)configureLoadingCell:(HNLoadingCell *)cell {
    if (self.dataCoordinator.isFetching) {
        [cell.activityIndicatorView startAnimating];
    } else {
        [cell.activityIndicatorView stopAnimating];
    }
}

- (NSIndexPath *)loadingCellIndexPath {
    return [NSIndexPath indexPathForRow:0 inSection:HNFeedViewControllerSectionLoading];
}

- (NSIndexPath *)emptyCellIndexPath {
    return [NSIndexPath indexPathForRow:0 inSection:HNFeedViewControllerSectionEmpty];
}


#pragma mark - Actions

- (void)onRefresh:(UIRefreshControl *)refreshControl {
    [self.dataCoordinator fetch];
}

- (void)updateFeed:(HNFeed *)feed {
    void (^updateBlock)(NSMutableArray *, NSMutableArray *, NSMutableArray *) = ^(NSMutableArray *inserts, NSMutableArray *deletes, NSMutableArray *reloads) {
        self.feed = feed;
    };

    [self.tableView performUpdatesWithOldArray:self.feed.items
                                      newArray:feed.items
                                       section:HNFeedViewControllerSectionData
                         dataSourceUpdateBlock:updateBlock];
}


#pragma mark - HNPostCellDelegate

- (void)postCellDidTapCommentButton:(HNPostCell *)postCell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:postCell];
    if (indexPath) {
        HNPost *post = self.feed.items[indexPath.row];
        HNCommentViewController *commentController = [[HNCommentViewController alloc] initWithPostID:post.pk];
        [self.navigationController pushViewController:commentController animated:YES];
    }
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return HNFeedViewControllerSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case HNFeedViewControllerSectionData:
            return self.feed.items.count;
        case HNFeedViewControllerSectionEmpty:
        case HNFeedViewControllerSectionLoading:
            return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier;
    NSUInteger section = indexPath.section;
    switch (section) {
        case HNFeedViewControllerSectionData:
            identifier = kPostCellIdentifier;
            break;
        case HNFeedViewControllerSectionEmpty:
            identifier = kEmptyCellIdentifier;
            break;
        case HNFeedViewControllerSectionLoading:
            identifier = kLoadingCellIdentifier;
            break;
    }
    NSAssert(identifier != nil, @"Unhandled table section");

    id cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    if (section == HNFeedViewControllerSectionData) {
        [self configureCell:cell forIndexPath:indexPath];
    } else if (section == HNFeedViewControllerSectionLoading) {
        [self configureLoadingCell:cell];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == HNFeedViewControllerSectionEmpty || indexPath.section == HNFeedViewControllerSectionLoading) {
        return self.dataCoordinator.isFetching ? 55.0 : 0.0;
    }

    [self configureCell:self.prototypeCell forIndexPath:indexPath];
    CGSize size = [self.prototypeCell sizeThatFits:CGSizeMake(CGRectGetWidth(self.tableView.bounds), CGFLOAT_MAX)];
    return size.height;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.section != HNFeedViewControllerSectionData) {
        return;
    }

    HNPost *post = self.feed.items[indexPath.row];

    [self.readPostIDs addIndex:post.pk];
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];

    UIViewController *controller;
    if (!post.URL.host || [[post.URL host] isEqualToString:@"news.ycombinator.com"]) {
        NSUInteger postID = [[post.URL hn_valueForQueryParameter:@"id"] integerValue];
        controller = [[HNCommentViewController alloc] initWithPostID:postID];
    } else {
        controller = [[HNWebViewController alloc] initWithPost:post];
    }

    if (self.navigationController) {
        [self.navigationController pushViewController:controller animated:YES];
    } else {
        [self presentViewController:controller animated:YES completion:nil];
    }
}


#pragma mark - HNDataCoordinatorDelegate

- (void)dataCoordinator:(HNDataCoordinator *)dataCoordinator didUpdateObject:(id)object {
    NSAssert([NSThread isMainThread], @"Delegate callbacks should be on the (registered) main thread");

    HNFeed *feed = (HNFeed *)object;

    if (self.isViewLoaded) {
        [self.refreshControl endRefreshing];

        if (self.feed) {
            [self performSelector:@selector(updateFeed:) withObject:feed afterDelay:0.23];
        } else {
            [self updateFeed:feed];
        }
    } else {
        self.feed = feed;
    }
}

- (void)dataCoordinator:(HNDataCoordinator *)dataCoordinator didError:(NSError *)error {
    NSAssert([NSThread isMainThread], @"Delegate callbacks should be on the (registered) main thread");

    if (!self.isViewLoaded) {
        return;
    }

    [self.refreshControl endRefreshing];

    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[[self loadingCellIndexPath]] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}

@end
