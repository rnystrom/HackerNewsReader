//
//  NSURL+HackerNews.m
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 5/8/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import "NSURL+HackerNews.h"

@implementation NSURL (HackerNews)

- (id)hn_valueForQueryParameter:(NSString *)parameter {
    if (!parameter) {
        return nil;
    }

    NSArray *components = [self.query componentsSeparatedByString:@"&"];
    for (NSString *pair in components) {
        NSArray *keyValue = [pair componentsSeparatedByString:@"="];
        if ([keyValue.firstObject isEqualToString:parameter]) {
            return keyValue.lastObject;
        }
    }
    return nil;
}

- (BOOL)isHackerNewsURL {
    NSRange range = [self.absoluteString rangeOfString:@"news.ycombinator.com"];
    if (range.length == 0) {
        return [self.path isEqualToString:@"item"] && [self hn_valueForQueryParameter:@"id"] != nil;
    } else {
        return YES;
    }
}

@end
