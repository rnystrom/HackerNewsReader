//
//  HNCommentParser.m
//  HackerNewsNetworker
//
//  Created by Ryan Nystrom on 4/11/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import "HNCommentParser.h"

#import <libkern/OSAtomic.h>

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
    return [self commentsFromParser:parser];
}

- (NSArray *)commentsFromParser:(TFHpple *)parser {
    static NSString * const commentQuery = @"//table[@id='hnmain']/tr[3]/td/table[2]/tr";
    static NSString * const userQuery = @"//span[@class='comhead']/a[1]";
    static NSString * const textQuery = @"//span[@class='comment']/font";
    static NSString * const removedQuery = @"//span[@class='comment']";
    static NSString * const indentQuery = @"//img[@src='s.gif']";
    static NSString * const permalinkQuery = @"//span[@class='comhead']/a[2]";

    NSArray *commentNodes = [parser searchWithXPathQuery:commentQuery];

    // use a mutable copy so we have objects to replace
    NSMutableArray *comments = [commentNodes mutableCopy];

    [commentNodes enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(TFHppleElement *commentNode, NSUInteger idx, BOOL *stop) {
        TFHppleElement *userNode = [[commentNode searchWithXPathQuery:userQuery] firstObject];
        NSString *username = [userNode content];
        HNUser *user = [[HNUser alloc] initWithUsername:username];

        TFHppleElement *permalinkNode = [[commentNode searchWithXPathQuery:permalinkQuery] firstObject];
        NSString *ageText = [permalinkNode content];
        NSString *postID = [[permalinkNode.attributes[@"href"] componentsSeparatedByString:@"item?id="] lastObject];
        NSUInteger pk = [postID integerValue];

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

        HNComment *comment = [[HNComment alloc] initWithUser:user components:components indent:indent pk:pk ageText:ageText];
        @synchronized(comments) {
            comments[idx] = comment;
        }
    }];

    return comments;
}

- (NSArray *)commentComponentsFromNode:(TFHppleElement *)node {
    NSMutableArray *components = [[NSMutableArray alloc] init];
    for (TFHppleElement *child in node.children) {
        [self recursiveComponentsFromNode:child bucket:components];
    }
    return components;
}

- (void)recursiveComponentsFromNode:(TFHppleElement *)node bucket:(NSMutableArray *)bucket {
    NSAssert(bucket != nil, @"Cannot traverse and collect comment nodes without a bucket");

    static NSDictionary *tagMap = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tagMap = @{
                   @"font": @(HNCommentTypeText),
                   @"i": @(HNCommentTypeItalic),
                   @"code": @(HNCommentTypeCode)
                   };
    });

    if ([node.tagName isEqualToString:@"p"]) {
        [bucket addObject:[HNCommentComponent newlineComponent]];
    }

    if ([node.tagName isEqualToString:@"text"]) {
        // at a leaf
//        id typeValue = tagMap[node.parent.tagName];
//        HNCommentType type = typeValue != nil ? [typeValue integerValue] : HNCommentTypeText;
        NSString *text = [node content];
//        HNCommentComponent *component = [[HNCommentComponent alloc] initWithText:text type:type];
//        [bucket addObject:component];
        [bucket addObjectsFromArray:[self componentsFromText:text]];
    } else if ([node.tagName isEqualToString:@"a"]) {
        // special-case links
        HNCommentComponent *component = [[HNCommentComponent alloc] initWithText:node.attributes[@"href"] type:HNCommentTypeLink];
        [bucket addObject:component];
    } else {
        // recurse
        for (TFHppleElement *child in node.children) {
            [self recursiveComponentsFromNode:child bucket:bucket];
        }
    }
}

- (HNCommentComponent *)removedComponentFromNode:(TFHppleElement *)node {
    NSString *text = [[node content] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    HNCommentComponent *component = [[HNCommentComponent alloc] initWithText:text type:HNCommentRemoved];
    return component;
}

- (NSArray *)componentsFromText:(NSString *)text {
    NSMutableArray *components = [[NSMutableArray alloc] init];
    NSError *error = nil;
    NSDataDetector *detector = [[NSDataDetector alloc] initWithTypes:NSTextCheckingTypeLink error:&error];
    __block NSRange previousRange = NSMakeRange(0, 0);
    [detector enumerateMatchesInString:text options:kNilOptions range:NSMakeRange(0, text.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSInteger previousLength = result.range.location - previousRange.location;

        // add the text in between, if there was any
        if (previousLength > 0) {
            NSString *substr = [text substringWithRange:NSMakeRange(previousRange.location, previousLength)];
            HNCommentComponent *component = [[HNCommentComponent alloc] initWithText:substr type:HNCommentTypeText];
            [components addObject:component];
        }
        previousRange = result.range;

        NSString *substr = [text substringWithRange:result.range];
        HNCommentComponent *component = [[HNCommentComponent alloc] initWithText:substr type:HNCommentTypeLink];
        [components addObject:component];
    }];

#if DEBUG
    if (error) {
        NSLog(@"%@",error.localizedDescription);
    }
#endif

    // add the tail component if necessary
    NSInteger addedLength = previousRange.location + previousRange.length;
    if (addedLength < text.length) {
        NSRange remainingRange = NSMakeRange(addedLength, text.length - addedLength);
        NSString *substr = [text substringWithRange:remainingRange];
        HNCommentComponent *component = [[HNCommentComponent alloc] initWithText:substr type:HNCommentTypeText];
        [components addObject:component];
    }

    return components;
}

@end
