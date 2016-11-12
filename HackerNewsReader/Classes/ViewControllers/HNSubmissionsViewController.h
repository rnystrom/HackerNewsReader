//
//  HNSubmissionsViewController.h
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 2/20/16.
//  Copyright © 2016 Ryan Nystrom. All rights reserved.
//

#import "HNFeedViewController.h"

@class HNUser;

@interface HNSubmissionsViewController : HNFeedViewController

- (void)configureWithUser:(HNUser *)user;

@end
