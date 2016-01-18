//
//  NSHTTPCookie+HackerNewsNetworker.m
//  HackerNewsNetworker
//
//  Created by Ryan Nystrom on 1/10/16.
//  Copyright © 2016 Ryan Nystrom. All rights reserved.
//

#import "NSHTTPCookie+HackerNewsNetworker.h"

@implementation NSHTTPCookie (HackerNewsNetworker)

- (NSArray *)hn_components {
    return [self.value componentsSeparatedByString:@"&"];
}

- (NSString *)hn_username {
    return [[self hn_components] firstObject];
}

- (NSString *)hn_session {
    return [[self hn_components] lastObject];
}

@end
