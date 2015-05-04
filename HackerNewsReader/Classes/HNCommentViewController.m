//
//  HNCommentViewController.m
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 4/9/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import "HNCommentViewController.h"

#import <HackerNewsNetworker/HNDataCoordinator.h>
#import <HackerNewsNetworker/HNCommentParser.h>

#import <HackerNewsKit/HNPost.h>
#import <HackerNewsKit/HNComment.h>

#import "HNCommentCell.h"
#import "UITableView+DataDiffing.h"
#import "HNComment+AttributedStrings.h"
#import "HNCommentHeaderCell.h"
#import "HNWebViewController.h"
#import "HNTextStorage.h"

typedef NS_ENUM(NSUInteger, HNCommentRow) {
    HNCommentRowUser,
    HNCommentRowText,
    HNCommentRowCount
};

static NSString * const kCommentCellIdentifier = @"kCommentCellIdentifier";
static NSString * const kCommentHeaderCellIdentifier = @"kCommentHeaderCellIdentifier";
static CGFloat const kCommentCellIndentationWidth = 20.0;

@interface HNCommentViewController() <HNDataCoordinatorDelegate, HNCommentCellDelegate>

@property (nonatomic, strong) HNDataCoordinator *dataCoordinator;
@property (nonatomic, strong, readonly) HNPost *post;
@property (nonatomic, strong) NSArray *comments;
//@property (nonatomic, strong) HNCommentCell *prototypeCell;
@property (nonatomic, strong) NSMutableSet *collapsedPaths;
@property (nonatomic, strong) NSDictionary *attributedCommentStrings;
@property (nonatomic, strong) HNTextStorage *textStorage;
@property (nonatomic, assign) CGFloat width;

@end

@implementation HNCommentViewController

- (instancetype)initWithPost:(HNPost *)post {
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        _post = [post copy];
        _collapsedPaths = [[NSMutableSet alloc] init];
        _attributedCommentStrings = [[NSMutableDictionary alloc] init];
        _textStorage = [[HNTextStorage alloc] init];

        NSAssert(_post != nil, @"Initializing a comments controller without a post is useless.");

        HNCommentParser *parser = [[HNCommentParser alloc] init];
        NSString *cacheName = [NSString stringWithFormat:@"%zi.comments",_post.pk];
        dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        _dataCoordinator = [[HNDataCoordinator alloc] initWithDelegate:self delegateQueue:q path:@"item" parser:parser cacheName:cacheName];
        [self fetch];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.width = CGRectGetWidth(self.view.bounds);

    self.title = NSLocalizedString(@"Comments", @"Title for the controller displaying a comments thread");
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];

    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(onRefresh:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;

    [self.tableView registerClass:HNCommentCell.class forCellReuseIdentifier:kCommentCellIdentifier];
    [self.tableView registerClass:HNCommentHeaderCell.class forCellReuseIdentifier:kCommentHeaderCellIdentifier];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if ([self.navigationController respondsToSelector:@selector(setHidesBarsOnSwipe:)]) {
        self.navigationController.hidesBarsOnSwipe = NO;
    }
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self.navigationController setToolbarHidden:YES animated:animated];

    if (self.dataCoordinator.isFetching) {
        [self.tableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];
        [self.refreshControl beginRefreshing];
    }
}


#pragma mark - Config

- (void)configureCommentCell:(HNCommentCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    HNComment *comment = self.comments[indexPath.section];
    NSUInteger indent = comment.indent;
    UIEdgeInsets insets = [HNCommentCell contentInsetsForIndentationLevel:indent indentationWidth:kCommentCellIndentationWidth];
    CGSize size = CGSizeMake(self.width - insets.left - insets.right, CGFLOAT_MAX);
    NSAttributedString *str = self.attributedCommentStrings[comment];
    cell.commentContentView.layer.contents = [self.textStorage renderedContentForAttributedString:str size:size];

    cell.delegate = self;
    cell.indentationWidth = comment.indent;
    cell.indentationLevel = kCommentCellIndentationWidth;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)configureHeaderCell:(HNCommentHeaderCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    HNComment *comment = self.comments[indexPath.section];
    cell.usernameLabel.text = comment.user.username;
    cell.indentationWidth = comment.indent;
    cell.indentationLevel = kCommentCellIndentationWidth;
}

- (void)updateComments:(NSArray *)comments {
    NSAssert([NSThread isMainThread], @"Delegate callbacks should be on the (registered) main thread");

    [self.refreshControl endRefreshing];

    NSArray *oldArray = self.comments;
    NSArray *newArray = comments;

    BOOL hadItems = oldArray.count > 0;
    NSMutableIndexSet *inserts = [[NSMutableIndexSet alloc] init];
    NSMutableIndexSet *reloads = [[NSMutableIndexSet alloc] init];
    [newArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSUInteger foundIdx = [oldArray indexOfObject:obj];
        if (!hadItems || foundIdx != idx) {
            [inserts addIndex:idx];
        } else {
            [reloads addIndex:idx];
        }
    }];

    BOOL hasItems = newArray.count > 0;
    NSMutableIndexSet *deletes = [[NSMutableIndexSet alloc] init];
    [oldArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSUInteger foundIdx = [newArray indexOfObject:obj];
        if (!hasItems || foundIdx != idx) {
            [deletes addIndex:idx];
        }
    }];

    self.comments = comments;

    [self.tableView beginUpdates];
    [self.tableView insertSections:inserts withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView deleteSections:deletes withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView reloadSections:reloads withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}


#pragma mark - Actions

- (void)onRefresh:(id)sender {
    [self fetch];
}

- (void)fetch {
    [self.dataCoordinator fetchWithParams:@{@"id": @(self.post.pk)}];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.comments.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return HNCommentRowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id cell;
    switch (indexPath.row) {
        case HNCommentRowUser: {
            cell = [tableView dequeueReusableCellWithIdentifier:kCommentHeaderCellIdentifier forIndexPath:indexPath];
            [self configureHeaderCell:cell forIndexPath:indexPath];
        }
            break;
        case HNCommentRowText: {
            cell = [tableView dequeueReusableCellWithIdentifier:kCommentCellIdentifier forIndexPath:indexPath];
            [self configureCommentCell:cell forIndexPath:indexPath];
        }
            break;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
    if ([self.collapsedPaths containsObject:indexPath]) {
        return 0.0;
    }

    switch (indexPath.row) {
        case HNCommentRowUser:
            return 30.0;
        case HNCommentRowText: {
            HNComment *comment = self.comments[indexPath.section];
            NSUInteger indent = comment.indent;
            UIEdgeInsets insets = [HNCommentCell contentInsetsForIndentationLevel:indent indentationWidth:kCommentCellIndentationWidth];
            CGSize size = CGSizeMake(self.width - insets.left - insets.right, CGFLOAT_MAX);
            NSAttributedString *str = self.attributedCommentStrings[comment];
            CGFloat height = [self.textStorage heightForAttributedString:str size:size];
            return height + insets.top + insets.bottom;
        }
    }
    return 0.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.row == HNCommentRowUser) {
        HNComment *selectedComment = self.comments[indexPath.section];
        NSMutableSet *indexes = [[NSMutableSet alloc] init];

        NSIndexPath *nextPath = [NSIndexPath indexPathForRow:HNCommentRowText inSection:indexPath.section];
        [indexes addObject:nextPath];

        for (NSUInteger i = indexPath.section + 1; i < self.comments.count; i++) {
            HNComment *followingComment = self.comments[i];
            if (followingComment.indent > selectedComment.indent) {
                [indexes addObject:[NSIndexPath indexPathForRow:HNCommentRowUser inSection:i]];
                [indexes addObject:[NSIndexPath indexPathForRow:HNCommentRowText inSection:i]];
            } else {
                break;
            }
        }

        BOOL willCollapse = ![self.collapsedPaths containsObject:nextPath];
        if (willCollapse) {
            [self.collapsedPaths unionSet:indexes];
        } else {
            [self.collapsedPaths minusSet:indexes];
        }

        HNCommentHeaderCell *selectedHeader = (HNCommentHeaderCell *)[tableView cellForRowAtIndexPath:indexPath];
        [selectedHeader setCollapsed:willCollapse];

        [tableView beginUpdates];
        [tableView endUpdates];
    }
}


#pragma mark - HNDataCoordinatorDelegate

- (void)dataCoordinator:(HNDataCoordinator *)dataCoordinator didUpdateObject:(NSArray *)comments {
    NSAssert(![NSThread isMainThread], @"Delegate callbacks should not be on the (registered) main thread");

    NSMutableDictionary *strings = [[NSMutableDictionary alloc] initWithCapacity:comments.count];
    for (HNComment *comment in comments) {
        NSAttributedString *str = [comment attributedString];
        if (str) {
            strings[comment] = str;

            NSUInteger indent = comment.indent;
            UIEdgeInsets insets = [HNCommentCell contentInsetsForIndentationLevel:indent indentationWidth:kCommentCellIndentationWidth];
            CGSize size = CGSizeMake(self.width - insets.left - insets.right, CGFLOAT_MAX);
            // warms the store
            [self.textStorage heightForAttributedString:str size:size];
        }
    }
    self.attributedCommentStrings = [strings copy];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateComments:comments];
    });
}

- (void)dataCoordinator:(HNDataCoordinator *)dataCoordinator didError:(NSError *)error {
    NSAssert(![NSThread isMainThread], @"Delegate callbacks should not be on the (registered) main thread");

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.refreshControl endRefreshing];
    });
}


#pragma mark - HNCommentCellDelegate

- (void)commentCell:(HNCommentCell *)commentCell didTapURL:(NSURL *)url {
    if (url) {
        HNWebViewController *controller = [[HNWebViewController alloc] initWithURL:url];
        [self.navigationController pushViewController:controller animated:YES];
    }
}


@end
