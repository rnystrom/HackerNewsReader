//
//  NSHTTPCookie+HackerNews.m
//  HackerNewsNetworker
//
//  Created by Ryan Nystrom on 1/10/16.
//  Copyright © 2016 Ryan Nystrom. All rights reserved.
//

#import "NSHTTPCookie+HackerNews.h"

@implementation NSHTTPCookie (HackerNews)

- (NSArray *)hackerNewsComponents {
    return [self.value componentsSeparatedByString:@"&"];
}

- (NSString *)hackerNewsUsername {
    return [[self hackerNewsComponents] firstObject];
}

- (NSString *)hackerNewsSession {
    return [[self hackerNewsComponents] lastObject];
}

@end
