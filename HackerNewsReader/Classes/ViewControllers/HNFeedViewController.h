//
//  HNFeedViewController.h
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 4/5/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

@import UIKit;

#import "HNDataCoordinator.h"

NS_ASSUME_NONNULL_BEGIN

@class HNDataCoordinator, HNReadPostStore;

@interface HNFeedViewController : UITableViewController <HNDataCoordinatorDelegate>

@property (nonatomic, strong, readonly) HNDataCoordinator *dataCoordinator;
@property (nonatomic, strong, readonly) HNReadPostStore *readPostStore;

@end

NS_ASSUME_NONNULL_END
