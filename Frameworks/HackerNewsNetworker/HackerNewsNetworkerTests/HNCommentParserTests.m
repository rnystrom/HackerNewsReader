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

@interface HNCommentParser (HNCommentParserTests)

- (NSArray *)commentsUsingConcurrentEnum:(NSData *)data;
- (NSArray *)commentsUsingDispatchGroups:(NSData *)data;
- (NSArray *)commentsUsingFastEnumFromData:(NSData *)data;

@end

@interface HNCommentParserTests : XCTestCase

@end

@implementation HNCommentParserTests

- (void)testCommentParsingCount {
    NSData *data = [self longCommentsData];
    id comments = [[[HNCommentParser alloc] init] parseDataFromResponse:data];
    NSUInteger commentCount = [comments count];
    XCTAssert(commentCount == 297, @"Comment count was %zi, expected 297", commentCount);
}

- (void)testCommentParsingFastEnum {
    NSData *data = [self longCommentsData];
    HNCommentParser *parser = [[HNCommentParser alloc] init];
    [self measureBlock:^{
        [parser commentsUsingFastEnumFromData:data];
    }];
}

- (void)testCommentParsingConcurrentEnum {
    NSData *data = [self longCommentsData];
    HNCommentParser *parser = [[HNCommentParser alloc] init];
    [self measureBlock:^{
        [parser commentsUsingConcurrentEnum:data];
    }];
}

- (void)testCommentParsingDispatchGroups {
    NSData *data = [self longCommentsData];
    HNCommentParser *parser = [[HNCommentParser alloc] init];
    [self measureBlock:^{
        [parser commentsUsingDispatchGroups:data];
    }];
}

//- (void)testCommentParsingPerformance {
//    NSData *data = [self longCommentsData];
//    [self measureBlock:^{
//        HNCommentParser *parser = [[HNCommentParser alloc] init];
//        [parser parseDataFromResponse:data];
//    }];
//}


#pragma mark - Helpers

- (NSData *)longCommentsData {
    NSString *path = [[NSBundle bundleForClass:self.class] pathForResource:@"msdn-ssh" ofType:@"html"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    return data;
}

@end
