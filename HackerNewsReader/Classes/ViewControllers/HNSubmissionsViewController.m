//
//  HNSubmissionsViewController.m
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 2/20/16.
//  Copyright © 2016 Ryan Nystrom. All rights reserved.
//

#import "HNSubmissionsViewController.h"

#import "HNUser.h"

#import "HNFeedParser.h"

@implementation HNSubmissionsViewController

@synthesize dataCoordinator = _dataCoordinator;

- (void)configureWithUser:(HNUser *)user {
    NSString *username = user.username;
    NSString *cacheName = [NSString stringWithFormat:@"%@.feed", username];
    HNFeedParser *parser = [[HNFeedParser alloc] init];
    _dataCoordinator = [[HNDataCoordinator alloc] initWithDelegate:self
                                                     delegateQueue:dispatch_get_main_queue()
                                                              path:@"submitted"
                                                            parser:parser
                                                         cacheName:cacheName];
    _dataCoordinator.staticParams = @{@"id": username};

    self.title = NSLocalizedString(@"Submissions", @"A list of submissions for a user");
}

@end
