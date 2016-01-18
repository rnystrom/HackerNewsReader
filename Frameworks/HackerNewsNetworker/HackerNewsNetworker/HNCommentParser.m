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

@implementation HNCommentParser

- (id <NSCoding>)parseDataFromResponse:(NSData *)data queries:(HNQueries *)queries {
    if (!data.length) {
        return nil;
    }

    TFHpple *parser = [[TFHpple alloc] initWithHTMLData:data];
    return [self commentsFromParser:parser queries:queries];
}

- (NSArray *)commentsFromParser:(TFHpple *)parser queries:(HNQueries *)queries {
    return [self commentsUsingConcurrentEnum:parser queries:queries];
}

- (NSArray *)commentsUsingConcurrentEnum:(TFHpple *)parser queries:(HNQueries *)queries {
    NSArray *nodes = [parser searchWithXPathQuery:queries.commentComments];

    // use a mutable copy so we have objects to replace
    __strong id* collected = (__strong id*)calloc(nodes.count, sizeof(id));

    [nodes enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(TFHppleElement *commentNode, NSUInteger idx, BOOL *stop) {
        HNComment *comment = [self commentFromNode:commentNode queries:queries];
        collected[idx] = comment;
    }];

    NSArray *comments = [NSArray arrayWithObjects:collected count:nodes.count];
    free(collected);

    return comments;
}

- (NSArray *)commentsUsingDispatchGroups:(TFHpple *)parser queries:(HNQueries *)queries {
    NSArray *nodes = [parser searchWithXPathQuery:queries.commentComments];

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
            HNComment *comment = [self commentFromNode:node queries:queries];
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

- (NSArray *)commentsUsingLazyDispatchGroups:(TFHpple *)parser queries:(HNQueries *)queries {
    NSArray *nodes = [parser searchWithXPathQuery:queries.commentComments];
    NSMutableArray *comments = [nodes mutableCopy];

    dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_apply(nodes.count, q, ^(size_t i) {
        HNComment *comment = [self commentFromNode:nodes[i] queries:queries];
        @synchronized(comments) {
            comments[i] = comment;
        }
    });

    return comments;
}

- (NSArray *)commentsUsingFastEnumFromData:(TFHpple *)parser queries:(HNQueries *)queries {
    NSArray *nodes = [parser searchWithXPathQuery:queries.commentComments];

    NSMutableArray *comments = [[NSMutableArray alloc] init];

    for (TFHppleElement *commentNode in nodes) {
        [comments addObject:[self commentFromNode:commentNode queries:queries]];
    }
    
    return comments;
}

- (HNComment *)commentFromNode:(TFHppleElement *)commentNode queries:(HNQueries *)queries {
    TFHppleElement *userNode = [[commentNode searchWithXPathQuery:queries.commentUser] firstObject];
    NSString *username = [userNode content];
    HNUser *user = [[HNUser alloc] initWithUsername:username];

    TFHppleElement *permalinkNode = [[commentNode searchWithXPathQuery:queries.commentPermalink] firstObject];
    NSString *ageText = [permalinkNode content];
    NSString *postID = [[permalinkNode.attributes[@"href"] componentsSeparatedByString:@"item?id="] lastObject];
    NSUInteger pk = [postID integerValue];

    TFHppleElement *textNode = [[commentNode searchWithXPathQuery:queries.commentText] firstObject];
    NSArray *components;
    if (textNode) {
        components = [self commentComponentsFromNode:textNode];
    } else {
        TFHppleElement *removedNode = [[commentNode searchWithXPathQuery:queries.commentRemoved] firstObject];
        components = @[[self removedComponentFromNode:removedNode]];
    }

    TFHppleElement *indentNode = [[commentNode searchWithXPathQuery:queries.commentIndent] firstObject];
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
        NSString *text = [node content];
        if ([text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length) {
            [bucket addObjectsFromArray:[self componentsFromText:text]];
        }
    } else if ([node.tagName isEqualToString:@"a"]) {
        // special-case links
        HNCommentComponent *component = [[HNCommentComponent alloc] initWithText:node.attributes[@"href"] type:HNCommentTypeLink];
        [bucket addObject:component];
    } else if (![node.attributes[@"class"] isEqualToString:@"reply"]) {
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

    if (error) {
        NSLog(@"%@",error.localizedDescription);
    }

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
