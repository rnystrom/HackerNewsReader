//
//  HNFeedDataSource.m
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 6/6/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import "HNFeedDataSource.h"

#import "HNFeed.h"
#import "HNPost.h"

#import "HNPostCell.h"
#import "HNReadPostStore.h"

static NSString * const kPostCellIdentifier = @"kPostCellIdentifier";

@interface HNFeedDataSource ()

@property (nonatomic, strong) HNReadPostStore *readPostStore;
@property (nonatomic, strong) HNPostCell *prototypeCell;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation HNFeedDataSource

- (instancetype)initWithTableView:(UITableView *)tableView readPostStore:(HNReadPostStore *)readPostStore {
    if (self = [super init]) {
        _tableView = tableView;
        _readPostStore = readPostStore;
        [_tableView registerClass:HNPostCell.class forCellReuseIdentifier:kPostCellIdentifier];
    }
    return self;
}

- (HNPostCell *)prototypeCell {
    if (!_prototypeCell) {
        _prototypeCell = [self.tableView dequeueReusableCellWithIdentifier:kPostCellIdentifier];
    }
    return _prototypeCell;
}

- (void)configureCell:(HNPostCell *)cell withPost:(HNPost *)post {
    BOOL postIsLink = post.pk == kHNPostPKIsLinkOnly;
    [cell setTitle:post.title];
    cell.read = [self.readPostStore hasReadPK:post.pk];
    [cell setCommentCount:post.commentCount];
    [cell setCommentButtonHidden:postIsLink];

    NSString *detailText = nil;
    if (!postIsLink) {
        detailText = [NSString stringWithFormat:NSLocalizedString(@"%zi points", @"Formatted string for the number of points"),post.score];
        if (post.URL.host.length) {
            detailText = [detailText stringByAppendingFormat:@" (%@)",post.URL.host];
        }
    }
    [cell setSubtitle:detailText];
}

- (HNPostCell *)cellForPostAtIndexPath:(NSIndexPath *)indexPath {
    HNPostCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kPostCellIdentifier forIndexPath:indexPath];
    [self configureCell:cell withPost:self.posts[indexPath.row]];
    return cell;
}

- (CGFloat)heightForPostAtIndexPath:(NSIndexPath *)indexPath {
    [self configureCell:self.prototypeCell withPost:self.posts[indexPath.row]];
    CGSize size = [self.prototypeCell sizeThatFits:CGSizeMake(CGRectGetWidth(self.tableView.bounds), CGFLOAT_MAX)];
    return size.height;
}

@end
