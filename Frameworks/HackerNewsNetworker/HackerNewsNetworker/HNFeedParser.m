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

#define USE_LOCAL_DATA 0

@implementation HNFeedParser

- (id <NSCopying, NSCoding>)parseDataFromResponse:(NSData *)data {
#if USE_LOCAL_DATA
    NSString *path = [[NSBundle mainBundle] pathForResource:@"hn-front-page" ofType:@"html"];
    data = [[NSData alloc] initWithContentsOfFile:path];
#endif

    if (!data.length) {
        return nil;
    }

    TFHpple *parser = [TFHpple hppleWithHTMLData:data];

    static NSString * const titlesQuery = @"//table[@id='hnmain']/tr[3]/td/table//td[@class='title'][not(@align)]/a";
    static NSString * const detailsQuery = @"//table[@id='hnmain']/tr[3]/td/table//td[@class='subtext']";
    static NSString * const scoreQuery = @"//span[@class='score']";
    static NSString * const commentsLinkQuery = @"//a[3]";

    NSArray *titleNodes = [parser searchWithXPathQuery:titlesQuery];
    NSArray *detailNodes = [parser searchWithXPathQuery:detailsQuery];

    NSMutableArray *items = [[NSMutableArray alloc] init];

    [titleNodes enumerateObjectsUsingBlock:^(TFHppleElement *titleNode, NSUInteger idx, BOOL *stop) {
        NSString *title = titleNode.content;
        NSString *link = titleNode.attributes[@"href"];

        if (idx < detailNodes.count) {
            TFHppleElement *detailNode = detailNodes[idx];
            NSString *scoreString = [[[detailNode searchWithXPathQuery:scoreQuery] valueForKeyPath:@"content"] firstObject];
            TFHppleElement *commentNode = [[detailNode searchWithXPathQuery:commentsLinkQuery] firstObject];
            NSString *commentString = [commentNode content];
            NSString *commentLink = commentNode.attributes[@"href"];
            NSString *postID = [[commentLink componentsSeparatedByString:@"item?id="] lastObject];

            scoreString = [[scoreString componentsSeparatedByString:@" "] firstObject];
            commentString = [[commentString componentsSeparatedByString:@" "] firstObject];

            HNPost *post = [[HNPost alloc] initWithTitle:title
                                                     url:[NSURL URLWithString:link]
                                                   score:[scoreString integerValue]
                                            commentCount:[commentString integerValue]
                                                      pk:[postID integerValue]
                                                    rank:idx+1];
            [items addObject:post];
        }
    }];

    NSArray *sortedItems = [items sortedArrayUsingSelector:@selector(compare:)];
    HNFeed *feed = [[HNFeed alloc] initWithItems:sortedItems createdDate:[NSDate date]];
    return feed;
}

@end
