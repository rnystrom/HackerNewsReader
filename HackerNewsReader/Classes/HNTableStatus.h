//
//  HNTableStatus.h
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 5/31/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface HNTableStatus : NSObject

- (instancetype)initWithTableView:(UITableView *)tableView emptyMessage:(NSString *)emptyMessage;

@property (nonatomic, assign) NSUInteger sections;

- (NSUInteger)additionalSectionCount;
- (NSUInteger)tailLoadingSection;
- (NSUInteger)emptyMessageSection;
- (NSUInteger)cellCountForSection:(NSUInteger)section;

- (id)cellForIndexPath:(NSIndexPath *)indexPath;

- (void)displayTailLoader;
- (void)hideTailLoader;
- (void)displayEmptyMessage;
- (void)hideEmptyMessage;

- (BOOL)indexPathIsStatus:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
