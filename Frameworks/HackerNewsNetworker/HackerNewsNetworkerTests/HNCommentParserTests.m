//
//  HNCommentParserTests.m
//  HackerNewsNetworker
//
//  Created by Ryan Nystrom on 6/2/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "HNCommentParser.h"
#import "TFHpple.h"

@interface HNCommentParserTests : XCTestCase

@end

@implementation HNCommentParserTests

- (void)testCommentParsingCount {
    NSData *data = [self longCommentsData];
    id comments = [[[HNCommentParser alloc] init] parseDataFromResponse:data];
    NSUInteger commentCount = [comments count];
    XCTAssert(commentCount == 297, @"Comment count was %zi, expected 297", commentCount);
}

- (void)testCommentParsingPerformance {
    NSData *data = [self longCommentsData];
    HNCommentParser *parser = [[HNCommentParser alloc] init];
    [self measureBlock:^{
        [parser parseDataFromResponse:data];
    }];
}


#pragma mark - Helpers

- (NSData *)longCommentsData {
    NSString *path = [[NSBundle bundleForClass:self.class] pathForResource:@"msdn-ssh" ofType:@"html"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    return data;
}

@end
