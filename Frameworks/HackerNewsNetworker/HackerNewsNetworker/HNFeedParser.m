//
//  HNParser.m
//  HackerNewsNetworker
//
//  Created by Ryan Nystrom on 4/5/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import "HNFeedParser.h"

#import <HackerNewsKit/HNFeed.h>
#import <HackerNewsKit/HNPost.h>

#import "TFHpple.h"

@implementation HNFeedParser

- (id <NSCopying, NSCoding>)parseDataFromResponse:(NSData *)data {
    if (!data.length) {
        return nil;
    }

    TFHpple *parser = [TFHpple hppleWithHTMLData:data];

    NSArray *titleNodes = [self titlesFromParser:parser];
    NSArray *detailNodes = [self detailsFromParser:parser];

    NSMutableArray *items = [[NSMutableArray alloc] init];

    [titleNodes enumerateObjectsUsingBlock:^(TFHppleElement *titleNode, NSUInteger idx, BOOL *stop) {
        if (idx < detailNodes.count) {
            TFHppleElement *detailNode = detailNodes[idx];

            HNPost *post = [self postFromTitleNode:titleNode detailNode:detailNode rank:idx + 1];
            [items addObject:post];
        }
    }];

    NSArray *sortedItems = [items sortedArrayUsingSelector:@selector(compare:)];
    HNFeed *feed = [[HNFeed alloc] initWithItems:sortedItems createdDate:[NSDate date]];
    return feed;
}

- (NSArray *)titlesFromParser:(TFHpple *)parser {
    static NSString * const titlesQuery = @"//table[@id='hnmain']/tr[3]/td/table//td[@class='title'][not(@align)]/a";
    return [parser searchWithXPathQuery:titlesQuery];
}

- (NSArray *)detailsFromParser:(TFHpple *)parser {
    static NSString * const detailsQuery = @"//table[@id='hnmain']/tr[3]/td/table//td[@class='subtext']";
    return [parser searchWithXPathQuery:detailsQuery];
}

- (HNPost *)postFromTitleNode:(TFHppleElement *)titleNode detailNode:(TFHppleElement *)detailNode rank:(NSUInteger)rank {
    static NSString * const scoreQuery = @"//span[@class='score']";
    static NSString * const commentsLinkQuery = @"//a[3]";

    NSString *title = titleNode.content;
    NSString *link = titleNode.attributes[@"href"];

    NSString *scoreString = [[[detailNode searchWithXPathQuery:scoreQuery] valueForKeyPath:@"content"] firstObject];
    TFHppleElement *commentNode = [[detailNode searchWithXPathQuery:commentsLinkQuery] firstObject];
    NSString *commentString = [commentNode content];
    NSString *commentLink = commentNode.attributes[@"href"];
    NSString *ageText = [commentNode content];
    NSString *postID = [[commentLink componentsSeparatedByString:@"item?id="] lastObject];

    scoreString = [[scoreString componentsSeparatedByString:@" "] firstObject];
    commentString = [[commentString componentsSeparatedByString:@" "] firstObject];

    HNPost *post = [[HNPost alloc] initWithTitle:title
                                         ageText:ageText
                                             url:[NSURL URLWithString:link]
                                           score:[scoreString integerValue]
                                    commentCount:[commentString integerValue]
                                              pk:[postID integerValue]
                                            rank:rank];
    return post;
}

@end
