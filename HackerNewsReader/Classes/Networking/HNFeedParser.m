//
//  HNParser.m
//  HackerNewsNetworker
//
//  Created by Ryan Nystrom on 4/5/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import "HNFeedParser.h"

#import "HNFeed.h"
#import "HNPost.h"

#import "TFHpple.h"
#import "NSString+HackerNewsNetworker.h"

@implementation HNFeedParser

- (id <NSCoding>)parseDataFromResponse:(NSData *)data queries:(HNQueries *)queries {
    if (!data.length) {
        return nil;
    }

    TFHpple *parser = [TFHpple hppleWithHTMLData:data];

    NSArray *titleNodes = [parser searchWithXPathQuery:queries.feedTitles];
    NSArray *detailNodes = [parser searchWithXPathQuery:queries.feedDetails];

    NSMutableArray *items = [[NSMutableArray alloc] init];

    [titleNodes enumerateObjectsUsingBlock:^(TFHppleElement *titleNode, NSUInteger idx, BOOL *stop) {
        if (idx < detailNodes.count) {
            TFHppleElement *detailNode = detailNodes[idx];

            HNPost *post = [self postFromTitleNode:titleNode detailNode:detailNode rank:idx + 1 queries:queries];
            [items addObject:post];
        }
    }];

    NSArray *sortedItems = [items sortedArrayUsingSelector:@selector(compare:)];
    HNFeed *feed = [[HNFeed alloc] initWithItems:sortedItems createdDate:[NSDate date]];
    return feed;
}

- (HNPost *)postFromTitleNode:(TFHppleElement *)titleNode detailNode:(TFHppleElement *)detailNode rank:(NSUInteger)rank queries:(HNQueries *)queries {
    NSParameterAssert(titleNode != nil);
    NSParameterAssert(detailNode != nil);
    NSParameterAssert(queries != nil);

    NSString *title = titleNode.content;
    NSString *link = titleNode.attributes[@"href"];

    NSString *scoreString = [[[detailNode searchWithXPathQuery:queries.feedScore] valueForKeyPath:@"content"] firstObject];
    TFHppleElement *commentNode = [[detailNode searchWithXPathQuery:queries.feedCommentNode] firstObject];
    NSString *commentString = [commentNode content];
    NSString *commentLink = commentNode.attributes[@"href"];
    NSString *ageText = [commentNode content];
    NSString *postID = [commentLink hn_queryParameters][@"id"];

    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    scoreString = [[scoreString componentsSeparatedByCharactersInSet:whitespace] firstObject];

    NSUInteger commentScore = 0;
    NSArray *commentComponents = [commentString componentsSeparatedByCharactersInSet:whitespace];
    if ([[[commentComponents lastObject] lowercaseString] hasPrefix:@"comment"]) {
        commentScore = [[commentComponents firstObject] integerValue];
    }

    HNPost *post = [[HNPost alloc] initWithTitle:title
                                         ageText:ageText
                                             url:[NSURL URLWithString:link]
                                           score:[scoreString integerValue]
                                    commentCount:commentScore
                                              pk:[postID integerValue]
                                            rank:rank];
    return post;
}

@end
