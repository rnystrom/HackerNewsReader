//
//  HNTopViewController.m
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 6/6/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import "HNTopViewController.h"

#import <HackerNewsNetworker/HNFeedParser.h>

#import "HNReadPostStore.h"

@interface HNTopViewController ()

@end

@implementation HNTopViewController

@synthesize readPostStore = _readPostStore, dataCoordinator = _dataCoordinator;

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.title = NSLocalizedString(@"Hacker News", @"The name of the Hacker News website");

        _readPostStore = [[HNReadPostStore alloc] initWithStoreName:@"read_posts.cache"];

        HNFeedParser *parser = [[HNFeedParser alloc] init];
        NSString *cacheName = @"latest.feed";
        _dataCoordinator = [[HNDataCoordinator alloc] initWithDelegate:self
                                                         delegateQueue:dispatch_get_main_queue()
                                                                  path:@"news"
                                                                parser:parser
                                                             cacheName:cacheName];
    }
    return self;
}

@end
