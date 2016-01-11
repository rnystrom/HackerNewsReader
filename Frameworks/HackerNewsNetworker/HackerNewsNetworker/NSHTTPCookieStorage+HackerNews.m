//
//  NSHTTPCookieStorage+HackerNews.m
//  HackerNewsNetworker
//
//  Created by Ryan Nystrom on 1/10/16.
//  Copyright © 2016 Ryan Nystrom. All rights reserved.
//

#import "NSHTTPCookieStorage+HackerNews.h"

@implementation NSHTTPCookieStorage (HackerNews)

- (NSHTTPCookie *)hackerNewsSessionCookie {
    static NSString *const kHackerNewsDomain = @"news.ycombinator.com";
    static NSString *const kHackerNewsUserName = @"user";
    for (NSHTTPCookie *cookie in self.cookies) {
        if ([cookie.domain isEqualToString:kHackerNewsDomain] && [cookie.name isEqualToString:kHackerNewsUserName]) {
            return cookie;
        }
    }
    return nil;
}

@end
