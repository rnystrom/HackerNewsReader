//
//  HNFeedViewController.h
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 4/5/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

@import UIKit;

#import <HackerNewsNetworker/HNDataCoordinator.h>

@class HNDataCoordinator, HNReadPostStore;

@interface HNFeedViewController : UITableViewController <HNDataCoordinatorDelegate>

@property (nonatomic, strong, readonly) HNDataCoordinator *dataCoordinator;
@property (nonatomic, strong, readonly) HNReadPostStore *readPostStore;

@end
