//
//  HNFeedDataSource.h
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 6/6/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

@import UIKit;

@class HNReadPostStore, HNPostCell, HNFeed;

@interface HNFeedDataSource : NSObject

- (instancetype)initWithTableView:(UITableView *)tableView readPostStore:(HNReadPostStore *)readPostStore;

@property (nonatomic, copy) NSArray *posts;

- (HNPostCell *)cellForPostAtIndexPath:(NSIndexPath *)indexPath;

- (CGFloat)heightForPostAtIndexPath:(NSIndexPath *)indexPath;

@end
