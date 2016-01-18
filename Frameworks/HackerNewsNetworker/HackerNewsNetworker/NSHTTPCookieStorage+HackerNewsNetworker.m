//
//  NSHTTPCookieStorage+HackerNewsNetworker.m
//  HackerNewsNetworker
//
//  Created by Ryan Nystrom on 1/10/16.
//  Copyright © 2016 Ryan Nystrom. All rights reserved.
//

#import "NSHTTPCookieStorage+HackerNewsNetworker.h"

#import <HackerNewsKit/HNUser.h>

#import "HNSession.h"
#import "NSHTTPCookie+HackerNewsNetworker.h"

@implementation NSHTTPCookieStorage (HackerNewsNetworker)

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

- (HNSession *)activeSession {
    NSHTTPCookie *cookie = [self hackerNewsSessionCookie];
    HNSession *session = nil;
    NSString *username = [cookie hackerNewsUsername];
    NSString *sessionKey = [cookie hackerNewsSession];
    if (username.length && sessionKey.length) {
        HNUser *user = [[HNUser alloc] initWithUsername:username];
        session = [[HNSession alloc] initWithUser:user session:sessionKey];
    }
    return session;
}

@end
