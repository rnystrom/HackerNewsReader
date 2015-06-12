//
//  HNCommentViewController.m
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 4/9/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import "HNCommentViewController.h"

#import <HackerNewsNetworker/HNDataCoordinator.h>
#import <HackerNewsNetworker/HNPageParser.h>

#import <HackerNewsKit/HNPage.h>

#import <MessageUI/MessageUI.h>

#import "AttributedCommentComponents.h"
#import "HNCommentCell.h"
#import "HNComment+AttributedStrings.h"
#import "HNCommentHeaderCell.h"
#import "HNWebViewController.h"
#import "HNTextStorage.h"
#import "HNPageHeaderView.h"
#import "NSURL+HackerNews.h"
#import "HNComment+Links.h"
#import "HNPage+Links.h"
#import "UIViewController+HNComment.h"
#import "UIViewController+UISplitViewController.h"
#import "UIViewController+ActivityIndicator.h"
#import "UIViewController+Sharing.h"
#import "UINavigationController+HNBarState.h"
#import "HNPostControllerHandling.h"
#import "HNSplitViewDelegate.h"

typedef NS_ENUM(NSUInteger, HNCommentRow) {
    HNCommentRowUser,
    HNCommentRowText,
    HNCommentRowCount
};

static NSString * const kCommentCellIdentifier = @"kCommentCellIdentifier";
static NSString * const kCommentHeaderCellIdentifier = @"kCommentHeaderCellIdentifier";
static CGFloat const kCommentCellIndentationWidth = 20.0;

@interface HNCommentViewController() <HNDataCoordinatorDelegate, HNCommentCellDelegate, HNPageHeaderViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, assign) NSUInteger postID;
@property (nonatomic, strong) HNDataCoordinator *dataCoordinator;
@property (nonatomic, strong) NSMutableSet *collapsedPaths;
@property (nonatomic, strong) NSDictionary *attributedCommentStrings;
@property (nonatomic, strong) HNTextStorage *textStorage;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, strong) HNPage *page;
@property (nonatomic, strong) UIBarButtonItem *shareBarButtonItem;

@end

@implementation HNCommentViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithPostID:(NSUInteger)postID {
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        _postID = postID;
        _collapsedPaths = [[NSMutableSet alloc] init];
        _attributedCommentStrings = [[NSMutableDictionary alloc] init];
        _textStorage = [[HNTextStorage alloc] init];

        HNPageParser *parser = [[HNPageParser alloc] init];
        NSString *cacheName = [NSString stringWithFormat:@"%zi.comments",_postID];
        dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        _dataCoordinator = [[HNDataCoordinator alloc] initWithDelegate:self delegateQueue:q path:@"item" parser:parser cacheName:cacheName];
        [self fetch];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(splitViewDisplayModeWillChange:) name:kHNSplitViewDelegateWillChangeDisplayMode object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Comments", @"Title for the controller displaying a comments thread");
    self.edgesForExtendedLayout = UIRectEdgeNone;

    [self configureLeftButtonAsDisplay];

    [self insertActivityIndicator];

    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(onRefresh:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;

    [self.tableView registerClass:HNCommentCell.class forCellReuseIdentifier:kCommentCellIdentifier];
    [self.tableView registerClass:HNCommentHeaderCell.class forCellReuseIdentifier:kCommentHeaderCellIdentifier];
    // cells have custom separators
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    UIBarButtonItem *share = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(onShare:)];
    share.enabled = NO;
    share.accessibilityLabel = NSLocalizedString(@"Share", @"Title of the share icon in the nav bar of the comment page");
    self.navigationItem.rightBarButtonItem = share;
    // will leave us with just a "<" back arrow and no text
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];

    self.shareBarButtonItem = share;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setHidesBarsOnSwipe:NO navigationBarHidden:NO toolbarHidden:YES animated:animated];
}

// only called on ios >7
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    UITableViewCell *topCell = self.tableView.visibleCells.firstObject;
    NSIndexPath *topIndexPath = [self.tableView indexPathForCell:topCell];

    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self setupHeaderViewWithPage:self.page];
        [self.tableView reloadData];
        [self.tableView scrollToRowAtIndexPath:topIndexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    } completion:nil];
}

// only called on ios 7
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    UITableViewCell *topCell = self.tableView.visibleCells.firstObject;
    NSIndexPath *topIndexPath = [self.tableView indexPathForCell:topCell];

    [UIView animateWithDuration:duration animations:^{
        [self.tableView reloadData];
        [self.tableView scrollToRowAtIndexPath:topIndexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    } completion:^(BOOL finished) {
        [self setupHeaderViewWithPage:self.page];
    }];
}


#pragma mark - Config

- (void)configureCommentCell:(HNCommentCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    HNComment *comment = self.page.comments[indexPath.section];
    CGFloat width = [self indentedWidthForComment:comment];
    NSAttributedString *str = self.attributedCommentStrings[comment];
    cell.commentContentView.layer.contents = [self.textStorage renderedContentForAttributedString:str width:width];
    cell.accessibilityLabel = str.string;
    cell.accessibilityHint = NSLocalizedString(@"Select for share options", @"Hint for comment cells");

    cell.delegate = self;
    cell.indentationWidth = comment.indent;
    cell.indentationLevel = kCommentCellIndentationWidth;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)configureHeaderCell:(HNCommentHeaderCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    HNComment *comment = self.page.comments[indexPath.section];
    NSString *usernameText = comment.user.username.length ? comment.user.username : NSLocalizedString(@"n/a", @"Not available (abbrev)");
    NSString *ageText = comment.ageText ?: @"";
    cell.titleLabel.text = [NSString stringWithFormat:@"%@ %@", usernameText, ageText];
    cell.indentationWidth = comment.indent;
    cell.indentationLevel = kCommentCellIndentationWidth;

    // faux header cell is never in collapsedPaths, so check if next path is
    NSIndexPath *nextPath = [NSIndexPath indexPathForItem:(indexPath.item + 1) inSection:indexPath.section];
    cell.collapsed = [self.collapsedPaths containsObject:nextPath];
}

- (void)setupHeaderViewWithPage:(HNPage *)page {
    // bail if our header doesn't really have any content
    NSString *title = page.post.title;
    if (!title.length) {
        return;
    }

    HNPageHeaderView *headerView = [[HNPageHeaderView alloc] init];
    headerView.delegate = self;
    [headerView setTitleText:page.post.title];
    [headerView setTextAttributedString:attributedStringFromComponents(page.textComponents)];

    NSString *detailText = [NSString stringWithFormat:NSLocalizedString(@"%zi points", @"Formatted string for the number of points"),page.post.score];
    if (page.post.URL.host.length) {
        detailText = [detailText stringByAppendingFormat:@" (%@)",page.post.URL.host];
    }
    [headerView setSubtitleText:detailText];
    CGSize headerSize = [headerView sizeThatFits:CGSizeMake(CGRectGetWidth(self.view.bounds), CGFLOAT_MAX)];
    headerView.frame = (CGRect){CGPointZero, headerSize};

    [UIView beginAnimations:nil context:NULL];
    self.tableView.tableHeaderView = headerView;
    [UIView commitAnimations];
}

- (void)updatePage:(HNPage *)page {
    NSAssert([NSThread isMainThread], @"Delegate callbacks should be on the (registered) main thread");

    self.shareBarButtonItem.enabled = page != nil;

    [self.refreshControl endRefreshing];
    [self hideActivityIndicator];

    [self setupHeaderViewWithPage:page];

    NSArray *oldArray = self.page.comments;
    NSArray *newArray = page.comments;

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

    self.page = page;

    [self.tableView beginUpdates];
    [self.tableView insertSections:inserts withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView deleteSections:deletes withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView reloadSections:reloads withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];

    NSUInteger count = page.comments.count;
    if (count) {
        NSString *commentFormatString = NSLocalizedString(@"%zi Comments", @"The number of comments in the thread");
        self.title = [NSString stringWithFormat:commentFormatString, count];
    } else {
        self.title = NSLocalizedString(@"No Comments", @"Title when there are no comments for a page");
    }
}

- (UIEdgeInsets)insetsForComment:(HNComment *)comment {
    return [HNCommentCell contentInsetsForIndentationLevel:comment.indent indentationWidth:kCommentCellIndentationWidth];
}

- (CGFloat)indentedWidthForComment:(HNComment *)comment {
    UIEdgeInsets insets = [self insetsForComment:comment];
    return CGRectGetWidth(self.view.bounds) - insets.left - insets.right;
}


#pragma mark - Actions

- (void)onRefresh:(id)sender {
    [self fetch];
}

- (void)fetch {
    [self.dataCoordinator fetchWithParams:@{@"id": @(self.postID)}];
}

- (void)didTapURL:(NSURL *)url {
    // email
    if ([url.absoluteString containsString:@"@"]) {
        if ([MFMailComposeViewController canSendMail]) {
            MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
            controller.mailComposeDelegate = self;
            [controller setToRecipients:@[url.absoluteString]];
            [self presentViewController:controller animated:YES completion:NULL];
        }
    } else {
        UIViewController *controller = viewControllerForURL(url);
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)onShare:(id)sender {
    [self shareURL:[self.page permalink] fromBarItem:self.shareBarButtonItem];
}


#pragma mark - Split View Messages

- (void)splitViewDisplayModeWillChange:(id)sender {
    [self setupHeaderViewWithPage:self.page];
    [self.tableView reloadData];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.page.comments.count;
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
    // UITableView internals use a different class that hashes differently from NSIndexPath
    indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
    if ([self.collapsedPaths containsObject:indexPath]) {
        return 0.0;
    }

    switch (indexPath.row) {
        case HNCommentRowUser:
            return 28.0;
        case HNCommentRowText: {
            HNComment *comment = self.page.comments[indexPath.section];
            NSUInteger indent = comment.indent;
            UIEdgeInsets insets = [HNCommentCell contentInsetsForIndentationLevel:indent indentationWidth:kCommentCellIndentationWidth];
            NSAttributedString *str = self.attributedCommentStrings[comment];
            CGFloat width = [self indentedWidthForComment:comment];
            CGFloat height = [self.textStorage heightForAttributedString:str width:width];
            return ceil(height + insets.top + insets.bottom);
        }
    }
    return 0.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.row == HNCommentRowUser) {
        HNComment *selectedComment = self.page.comments[indexPath.section];
        NSMutableSet *indexes = [[NSMutableSet alloc] init];

        NSIndexPath *nextPath = [NSIndexPath indexPathForRow:HNCommentRowText inSection:indexPath.section];
        [indexes addObject:nextPath];

        for (NSUInteger i = indexPath.section + 1; i < self.page.comments.count; i++) {
            HNComment *followingComment = self.page.comments[i];
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

- (void)dataCoordinator:(HNDataCoordinator *)dataCoordinator didUpdateObject:(HNPage *)page {
    NSAssert(![NSThread isMainThread], @"Delegate callbacks should not be on the (registered) main thread");

    NSMutableDictionary *strings = [[NSMutableDictionary alloc] initWithCapacity:page.comments.count];

    // precompute strings and heights for all text
    for (HNComment *comment in page.comments) {
        NSAttributedString *str = [comment attributedString];
        if (str) {
            strings[comment] = str;

            NSUInteger indent = comment.indent;
            UIEdgeInsets insets = [HNCommentCell contentInsetsForIndentationLevel:indent indentationWidth:kCommentCellIndentationWidth];
            CGFloat width = CGRectGetWidth(self.view.bounds) - insets.left - insets.right;
            // warms the store
            (void)[self.textStorage heightForAttributedString:str width:width];
        }
    }
    self.attributedCommentStrings = [strings copy];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self updatePage:page];
    });
}

- (void)dataCoordinator:(HNDataCoordinator *)dataCoordinator didError:(NSError *)error {
    NSAssert(![NSThread isMainThread], @"Delegate callbacks should not be on the (registered) main thread");

    dispatch_async(dispatch_get_main_queue(), ^{
        [self hideActivityIndicator];
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    });
}


#pragma mark - HNCommentCellDelegate

- (void)commentCell:(HNCommentCell *)commentCell didTapCommentAtPoint:(CGPoint)point {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:commentCell];
    HNComment *comment = self.page.comments[indexPath.section];
    CGFloat width = [self indentedWidthForComment:comment];
    NSAttributedString *str = self.attributedCommentStrings[comment];
    NSDictionary *attributes = [self.textStorage attributesForAttributedString:str width:width point:point];
    NSString *urlString = attributes[HNCommentLinkAttributeName];
    if (urlString) {
        [self didTapURL:[NSURL URLWithString:urlString]];
    }
}

- (void)commentCell:(HNCommentCell *)commentCell didLongPressAtPoint:(CGPoint)point {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:commentCell];
    HNComment *comment = self.page.comments[indexPath.section];
    [self showActionSheetForComment:comment fromView:commentCell];
}


#pragma mark - HNPageHeaderViewDelegate

- (void)pageHeader:(HNPageHeaderView *)pageHeader didTapText:(NSAttributedString *)text characterAtIndex:(NSUInteger)index {
    NSString *urlString = [text attributesAtIndex:index effectiveRange:nil][HNCommentLinkAttributeName];
    if (urlString) {
        [self didTapURL:[NSURL URLWithString:urlString]];
    }
}

- (void)pageHeaderDidTapTitle:(HNPageHeaderView *)pageHeader {
    if (![self.page.post.URL isHackerNewsURL]) {
        HNWebViewController *controller = [[HNWebViewController alloc] initWithPost:self.page.post];
        [self.navigationController pushViewController:controller animated:YES];
    }
}


#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
