//
//  NSURL+HackerNewsTests.m
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 6/16/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "NSURL+HackerNews.h"

@interface NSURL_HackerNewsTests : XCTestCase

@end

@implementation NSURL_HackerNewsTests

- (void)testHackerNewsFeedWithScheme {
    NSURL *url = [NSURL URLWithString:@"https://news.ycombinator.com"];
    XCTAssert([url isHackerNewsURL], @"URL %@ should be a valid Hacker News url", url.absoluteString);
}

- (void)testHackerNewsFeedWithoutScheme {
    NSURL *url = [NSURL URLWithString:@"news.ycombinator.com"];
    XCTAssert([url isHackerNewsURL], @"URL %@ should be a valid Hacker News url", url.absoluteString);
}

- (void)testHackerNewsCommentWithScheme {
    NSURL *url = [NSURL URLWithString:@"https://news.ycombinator.com/item?id=9725475"];
    XCTAssert([url isHackerNewsURL], @"URL %@ should be a valid Hacker News url", url.absoluteString);
}

- (void)testHackerNewsCommentWithoutScheme {
    NSURL *url = [NSURL URLWithString:@"news.ycombinator.com/item?id=9725475"];
    XCTAssert([url isHackerNewsURL], @"URL %@ should be a valid Hacker News url", url.absoluteString);
}

- (void)testNormalLinkWithScheme {
    NSURL *url = [NSURL URLWithString:@"facebook.com"];
    XCTAssert(![url isHackerNewsURL], @"URL %@ should not be a valid Hacker News url", url.absoluteString);
}

- (void)testNormalLinkWithoutScheme {
    NSURL *url = [NSURL URLWithString:@"https://facebook.com"];
    XCTAssert(![url isHackerNewsURL], @"URL %@ should not be a valid Hacker News url", url.absoluteString);
}

@end
