//
//  HNCommentParser.m
//  HackerNewsNetworker
//
//  Created by Ryan Nystrom on 4/11/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import "HNCommentParser.h"

#import <HackerNewsKit/HNComment.h>

#import "TFHpple.h"

#define USE_LOCAL_DATA 0

@implementation HNCommentParser

- (id <NSCopying, NSCoding>)parseDataFromResponse:(NSData *)data {
#if USE_LOCAL_DATA
    NSString *path = [[NSBundle mainBundle] pathForResource:@"hn-comments" ofType:@"html"];
    data = [[NSData alloc] initWithContentsOfFile:path];
#endif

    if (!data.length) {
        return nil;
    }

    TFHpple *parser = [TFHpple hppleWithHTMLData:data];

    static NSString * const commentQuery = @"//table[@id='hnmain']/tr[3]/td/table[2]/tr";
    static NSString * const userQuery = @"//span[@class='comhead']/a[1]";
    static NSString * const textQuery = @"//span[@class='comment']/font";
    static NSString * const removedQuery = @"//span[@class='comment']";
    static NSString * const indentQuery = @"//img[@src='s.gif']";

    NSArray *commentNodes = [parser searchWithXPathQuery:commentQuery];

    NSMutableArray *comments = [[NSMutableArray alloc] init];

    [commentNodes enumerateObjectsUsingBlock:^(TFHppleElement *commentNode, NSUInteger idx, BOOL *stop) {
        TFHppleElement *userNode = [[commentNode searchWithXPathQuery:userQuery] firstObject];
        NSString *username = [userNode content];
        HNUser *user = [[HNUser alloc] initWithUsername:username];

        TFHppleElement *textNode = [[commentNode searchWithXPathQuery:textQuery] firstObject];
        NSArray *components;
        if (textNode) {
            components = [self commentComponentsFromNode:textNode];
        } else {
            TFHppleElement *removedNode = [[commentNode searchWithXPathQuery:removedQuery] firstObject];
            components = @[[self removedComponentFromNode:removedNode]];
        }

        TFHppleElement *indentNode = [[commentNode searchWithXPathQuery:indentQuery] firstObject];
        NSString *indentText = indentNode.attributes[@"width"];
        NSUInteger indent = indentText.integerValue / 40;

        HNComment *comment = [[HNComment alloc] initWithUser:user components:components indent:indent];
        [comments addObject:comment];
    }];
    
    return comments;
}

- (NSArray *)commentComponentsFromNode:(TFHppleElement *)node {
    NSMutableArray *components = [[NSMutableArray alloc] init];
    for (TFHppleElement *child in node.children) {
        [self recursiveComponentsFromNode:child bucket:components newline:NO];
    }
    return components;
}

- (void)recursiveComponentsFromNode:(TFHppleElement *)node bucket:(NSMutableArray *)bucket newline:(BOOL)newline {
    NSAssert(bucket != nil, @"Cannot traverse and collect comment nodes without a bucket");

    NSDictionary * tagMap = @{
                              @"p": @(HNCommentTypeText),
                              @"text": @(HNCommentTypeText),
                              @"font": @(HNCommentTypeText),
                              @"i": @(HNCommentTypeItalic),
                              @"pre": @(HNCommentTypeCode),
                              @"code": @(HNCommentTypeCode)
                              };

    // at a leaf
    if ([node.tagName isEqualToString:@"text"]) {
        id typeValue = tagMap[node.parent.tagName];
        if (typeValue) {
            HNCommentType type = [typeValue integerValue];
            NSString *text = [[node content] stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
            HNCommentComponent *component = [[HNCommentComponent alloc] initWithText:text type:type newline:newline];
            [bucket addObject:component];
        } else{
            NSLog(@"Node unsupported with parent type %@: %@",node.parent.tagName,node);
        }
    } else if ([node.tagName isEqualToString:@"a"]) {
        HNCommentComponent *component = [[HNCommentComponent alloc] initWithText:node.attributes[@"href"] type:HNCommentTypeLink newline:newline];
        [bucket addObject:component];
    } else {
        id first = node.children.firstObject;
        for (TFHppleElement *child in node.children) {
            BOOL childNewline = [node.tagName isEqualToString:@"p"] && [child isEqual:first];
            [self recursiveComponentsFromNode:child bucket:bucket newline:childNewline];
        }
    }
}

- (HNCommentComponent *)removedComponentFromNode:(TFHppleElement *)node {
    NSString *text = [[node content] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    HNCommentComponent *component = [[HNCommentComponent alloc] initWithText:text type:HNCommentRemoved newline:NO];
    return component;
}

@end
