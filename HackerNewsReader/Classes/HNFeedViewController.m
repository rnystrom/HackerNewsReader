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
#import "HNTableStatus.h"
#import "HNNavigationController.h"

typedef NS_ENUM(NSUInteger, HNFeedViewControllerSection) {
    HNFeedViewControllerSectionData,
    HNFeedViewControllerSectionCount
};

static NSString * const kPostCellIdentifier = @"kPostCellIdentifier";
static NSUInteger const kItemsPerPage = 30;

@interface HNFeedViewController () <HNDataCoordinatorDelegate, HNPostCellDelegate>

@property (nonatomic, strong) HNDataCoordinator *dataCoordinator;
@property (nonatomic, copy) HNFeed *feed;
@property (nonatomic, strong) HNPostCell *prototypeCell;
@property (nonatomic, strong) NSMutableIndexSet *readPostIDs;
@property (nonatomic, assign) BOOL didRefresh;
@property (nonatomic, strong) HNTableStatus *tableStatus;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end

@implementation HNFeedViewController

- (void)hn_init {
    self.title = NSLocalizedString(@"Hacker News", @"The name of the Hacker News website");

    _readPostIDs = [[NSMutableIndexSet alloc] init];

    HNFeedParser *parser = [[HNFeedParser alloc] init];
    NSString *cacheName = @"latest.feed";
    _dataCoordinator = [[HNDataCoordinator alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue() path:@"news" parser:parser cacheName:cacheName];
}

- (instancetype)init {
    if (self = [super init]) {
        [self hn_init];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self hn_init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.edgesForExtendedLayout = UIRectEdgeNone;

    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.activityIndicator startAnimating];
    [self.view addSubview:self.activityIndicator];

    [self fetchWithParams:nil refresh:YES];

    [self.tableView registerClass:HNPostCell.class forCellReuseIdentifier:kPostCellIdentifier];
    self.tableView.tableFooterView = [[UIView alloc] init];

    NSString *emptyMessage = NSLocalizedString(@"Failed loading feed", @"Cannot load data for the list");
    self.tableStatus = [[HNTableStatus alloc] initWithTableView:self.tableView emptyMessage:emptyMessage];
    self.tableStatus.sections = HNFeedViewControllerSectionCount;

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
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    CGRect bounds = self.view.bounds;
    self.activityIndicator.center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds) - self.navigationController.topLayoutGuide.length);
    self.activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
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
    BOOL postIsLink = post.pk == kHNPostPKIsLinkOnly;
    cell.titleLabel.text = post.title;
    cell.read = [self.readPostIDs containsIndex:post.pk];
    [cell setCommentCount:post.commentCount];
    [cell setCommentButtonHidden:postIsLink];
    cell.delegate = self;

    NSString *detailText = nil;
    if (!postIsLink) {
        detailText = [NSString stringWithFormat:NSLocalizedString(@"%zi points", @"Formatted string for the number of points"),post.score];
        if (post.URL.host.length) {
            detailText = [detailText stringByAppendingFormat:@" (%@)",post.URL.host];
        }
    }
    cell.subtitleLabel.text = detailText;
}


#pragma mark - Actions

- (void)fetchWithParams:(NSDictionary *)params refresh:(BOOL)refresh {
    if ([self.dataCoordinator isFetching]) {
        return;
    }

    self.didRefresh = refresh;

    [self.dataCoordinator fetchWithParams:params];
}

- (void)onRefresh:(UIRefreshControl *)refreshControl {
    [self fetchWithParams:nil refresh:YES];
}

- (void)updateFeed:(HNFeed *)feed {
    [self.tableStatus hideTailLoader];
    [self.activityIndicator stopAnimating];
    [self.activityIndicator removeFromSuperview];

    if (feed.items.count == 0) {
        [self.tableStatus displayEmptyMessage];
    } else {
        [self.tableStatus hideEmptyMessage];
    }

    // if not refreshing, append items
    if (!self.didRefresh) {
        feed = [self.feed feedByMergingFeed:feed];

        NSUInteger currentCount = self.feed.items.count;
        NSMutableArray *inserts = [[NSMutableArray alloc] init];
        [feed.items enumerateObjectsUsingBlock:^(HNPost *post, NSUInteger idx, BOOL *stop) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:idx inSection:HNFeedViewControllerSectionData];
            if (idx >= currentCount) {
                [inserts addObject:indexPath];
            }
        }];

        self.feed = feed;

        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:inserts withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    } else {
        self.didRefresh = NO;
        self.feed = feed;
        [self.tableView reloadData];
    }
}


#pragma mark - HNPostCellDelegate

- (void)postCellDidTapCommentButton:(HNPostCell *)postCell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:postCell];
    if (indexPath) {
        HNPost *post = self.feed.items[indexPath.row];
        HNCommentViewController *commentController = [[HNCommentViewController alloc] initWithPostID:post.pk];
        HNNavigationController *navigationController = [[HNNavigationController alloc] initWithRootViewController:commentController];
        [self.splitViewController showDetailViewController:navigationController sender:self];
    }
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return HNFeedViewControllerSectionCount + [self.tableStatus additionalSectionCount];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == HNFeedViewControllerSectionData) {
        return self.feed.items.count;
    } else {
        return [self.tableStatus cellCountForSection:section];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger section = indexPath.section;

    if (section == HNFeedViewControllerSectionData) {
        id cell = [tableView dequeueReusableCellWithIdentifier:kPostCellIdentifier forIndexPath:indexPath];
        [self configureCell:cell forIndexPath:indexPath];
        return cell;
    } else {
        return [self.tableStatus cellForIndexPath:indexPath];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == HNFeedViewControllerSectionData) {
        [self configureCell:self.prototypeCell forIndexPath:indexPath];
        CGSize size = [self.prototypeCell sizeThatFits:CGSizeMake(CGRectGetWidth(self.tableView.bounds), CGFLOAT_MAX)];
        return size.height;
    }

    return 55.0;
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

    HNNavigationController *navigationController = [[HNNavigationController alloc] initWithRootViewController:controller];
    [self.splitViewController showDetailViewController:navigationController sender:self];
}


#pragma mark - HNDataCoordinatorDelegate

- (void)dataCoordinator:(HNDataCoordinator *)dataCoordinator didUpdateObject:(id)object {
    NSAssert([NSThread isMainThread], @"Delegate callbacks should be on the (registered) main thread");

    HNFeed *feed = (HNFeed *)object;

    if (self.isViewLoaded) {
        if (self.refreshControl.isRefreshing) {
            [self.refreshControl endRefreshing];
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

#if DEBUG
    NSLog(@"%@",error.localizedDescription);
#endif

    [self.activityIndicator stopAnimating];
    [self.activityIndicator removeFromSuperview];
    [self.tableStatus displayEmptyMessage];
    [self.refreshControl endRefreshing];
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    CGFloat height = CGRectGetHeight(self.view.bounds);
    CGFloat offset = targetContentOffset->y + height;
    CGFloat contentHeight = scrollView.contentSize.height;
    if (contentHeight > height && offset > contentHeight - height && !self.dataCoordinator.isFetching) {
        NSUInteger items = [self tableView:self.tableView numberOfRowsInSection:HNFeedViewControllerSectionData];
        NSUInteger page = items / kItemsPerPage + 1;
        [self fetchWithParams:@{@"p": @(page)} refresh:NO];
        [self.tableStatus displayTailLoader];
    }
}

@end
