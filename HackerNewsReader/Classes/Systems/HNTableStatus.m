//
//  HNTableStatus.m
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 5/31/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import "HNTableStatus.h"

#import "HNLoadingCell.h"
#import "HNEmptyTableCell.h"

static NSString * const kEmptyCellIdentifier = @"kEmptyCellIdentifier";
static NSString * const kLoadingCellIdentifier = @"kLoadingCellIdentifier";

@interface HNTableStatus ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign, getter=isDisplayingTailLoader) BOOL displayingTailLoader;
@property (nonatomic, assign, getter=isDisplayingEmptyMessage) BOOL displayingEmptyMessage;
@property (nonatomic, copy) NSString *emptyMessage;

@end

@implementation HNTableStatus

- (instancetype)initWithTableView:(UITableView *)tableView emptyMessage:(NSString *)emptyMessage {
    if (self = [super init]) {
        _tableView = tableView;
        _emptyMessage = [emptyMessage copy];

        [_tableView registerClass:HNEmptyTableCell.class forCellReuseIdentifier:kEmptyCellIdentifier];
        [_tableView registerClass:HNLoadingCell.class forCellReuseIdentifier:kLoadingCellIdentifier];
    }
    return self;
}


#pragma mark - Public API

- (NSUInteger)additionalSectionCount {
    return 2;
}

- (NSUInteger)tailLoadingSection {
    return [self emptyMessageSection] + 1;
}

- (NSUInteger)emptyMessageSection {
    return self.sections;
}

- (NSUInteger)cellCountForSection:(NSUInteger)section {
    NSUInteger count = NSNotFound;
    if (section == [self tailLoadingSection]) {
        count = self.isDisplayingTailLoader ? 1 : 0;
    } else if (section == [self emptyMessageSection]) {
        count = self.isDisplayingEmptyMessage ? 1 : 0;
    }
    NSAssert(count != NSNotFound, @"Unhandled section %zi for table status", section);
    return count;
}

- (void)displayTailLoader {
    if (!self.isDisplayingTailLoader) {
        self.displayingTailLoader = YES;
        NSIndexPath *indexPath = [self tailLoaderCellIndexPath];
        [self doShow:YES atIndexPath:indexPath];
        HNLoadingCell *cell = (HNLoadingCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        [cell.activityIndicatorView startAnimating];
    }
}

- (void)hideTailLoader {
    if (self.isDisplayingTailLoader) {
        self.displayingTailLoader = NO;
        NSIndexPath *indexPath = [self tailLoaderCellIndexPath];
        [self doShow:NO atIndexPath:indexPath];
        HNLoadingCell *cell = (HNLoadingCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        [cell.activityIndicatorView stopAnimating];
    }
}

- (void)displayEmptyMessage {
    if (!self.isDisplayingEmptyMessage) {
        self.displayingEmptyMessage = YES;
        [self doShow:YES atIndexPath:[self emptyCellIndexPath]];
    }
}

- (void)hideEmptyMessage {
    if (self.isDisplayingEmptyMessage) {
        self.displayingEmptyMessage = NO;
        [self doShow:NO atIndexPath:[self emptyCellIndexPath]];
    }
}

- (id)cellForIndexPath:(NSIndexPath *)indexPath {
    id cell = nil;
    if (indexPath.section == [self tailLoadingSection]) {
        HNLoadingCell *loadingCell = [self.tableView dequeueReusableCellWithIdentifier:kLoadingCellIdentifier forIndexPath:indexPath];
        if (self.isDisplayingTailLoader) {
            [loadingCell.activityIndicatorView startAnimating];
        }
        cell = loadingCell;
    } else if (indexPath.section == [self emptyMessageSection]) {
        HNEmptyTableCell *emptyCell = [self.tableView dequeueReusableCellWithIdentifier:kEmptyCellIdentifier forIndexPath:indexPath];
        emptyCell.textLabel.text = self.emptyMessage;
        cell = emptyCell;
    }
    NSAssert(cell != nil, @"Unhandled table status cell for section %zi",indexPath.section);
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

- (BOOL)indexPathIsStatus:(NSIndexPath *)indexPath {
    return indexPath.section == [self tailLoadingSection] || indexPath.section == [self emptyMessageSection];
}


#pragma mark - Private API

- (NSIndexPath *)emptyCellIndexPath {
    return [NSIndexPath indexPathForItem:0 inSection:[self emptyMessageSection]];
}

- (NSIndexPath *)tailLoaderCellIndexPath {
    return [NSIndexPath indexPathForItem:0 inSection:[self tailLoadingSection]];
}

- (void)doShow:(BOOL)doShow atIndexPath:(NSIndexPath *)indexPath {
    [self.tableView beginUpdates];
    if (doShow) {
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else {
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    [self.tableView endUpdates];
}

@end
