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

    TFHpple *parser = [[TFHpple alloc] initWithHTMLData:data];
    return [self commentsUsingLazyDispatchGroups:parser];
}

static NSString * const commentQuery = @"//table[@id='hnmain']/tr[3]/td/table[2]/tr";
static NSString * const userQuery = @"//span[@class='comhead']/a[1]";
static NSString * const textQuery = @"//span[@class='comment']/font";
static NSString * const removedQuery = @"//span[@class='comment']";
static NSString * const indentQuery = @"//img[@src='s.gif']";
static NSString * const permalinkQuery = @"//span[@class='comhead']/a[2]";

- (NSArray *)commentsFromParser:(TFHpple *)parser {
    return [self commentsUsingLazyDispatchGroups:parser];
}

- (NSArray *)commentsUsingConcurrentEnum:(NSData *)data {
    TFHpple *parser = [TFHpple hppleWithHTMLData:data];
    NSArray *nodes = [parser searchWithXPathQuery:commentQuery];

    // use a mutable copy so we have objects to replace
    NSMutableArray *comments = [nodes mutableCopy];

    [nodes enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(TFHppleElement *commentNode, NSUInteger idx, BOOL *stop) {
        HNComment *comment = [self commentFromNode:commentNode];
        @synchronized(comments) {
            comments[idx] = comment;
        }
    }];

    return comments;
}

- (NSArray *)commentsUsingDispatchGroups:(TFHpple *)parser {
    NSArray *nodes = [parser searchWithXPathQuery:commentQuery];

    NSMutableArray *comments = [nodes mutableCopy];
    const NSUInteger groupSize = 75;

    NSUInteger iterations = ceil(nodes.count / (double)groupSize);
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_apply(iterations, q, ^(size_t i) {
        NSUInteger location = i * groupSize;
        NSUInteger length = MIN(groupSize, nodes.count - location);
        NSArray *subNodes = [nodes subarrayWithRange:NSMakeRange(location, length)];
        NSMutableArray *subComments = [[NSMutableArray alloc] init];
        NSMutableIndexSet *indexes = [[NSMutableIndexSet alloc] init];
        [subNodes enumerateObjectsUsingBlock:^(TFHppleElement *node, NSUInteger idx, BOOL *stop) {
            HNComment *comment = [self commentFromNode:node];
            [subComments addObject:comment];
            [indexes addIndex:(location + idx)];
        }];
        @synchronized(comments) {
            [comments replaceObjectsAtIndexes:indexes withObjects:subComments];
        }
    });

    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);

    return comments;
}

- (NSArray *)commentsUsingLazyDispatchGroups:(TFHpple *)parser {
    NSArray *nodes = [parser searchWithXPathQuery:commentQuery];
    NSMutableArray *comments = [nodes mutableCopy];

    dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_apply(nodes.count, q, ^(size_t i) {
        HNComment *comment = [self commentFromNode:nodes[i]];
        @synchronized(comments) {
            comments[i] = comment;
        }
    });

    return comments;
}

- (NSArray *)commentsUsingFastEnumFromData:(TFHpple *)parser {
    NSArray *nodes = [parser searchWithXPathQuery:commentQuery];

    NSMutableArray *comments = [[NSMutableArray alloc] init];

    for (TFHppleElement *commentNode in nodes) {
        [comments addObject:[self commentFromNode:commentNode]];
    }
    
    return comments;
}

- (HNComment *)commentFromNode:(TFHppleElement *)commentNode {
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
    return comment;
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
