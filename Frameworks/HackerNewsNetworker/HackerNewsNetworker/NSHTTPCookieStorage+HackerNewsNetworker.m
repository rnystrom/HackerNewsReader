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

- (NSHTTPCookie *)hn_sessionCookie {
    static NSString *const kHackerNewsDomain = @"news.ycombinator.com";
    static NSString *const kHackerNewsUserName = @"user";
    for (NSHTTPCookie *cookie in self.cookies) {
        if ([cookie.domain isEqualToString:kHackerNewsDomain] && [cookie.name isEqualToString:kHackerNewsUserName]) {
            return cookie;
        }
    }
    return nil;
}

- (HNSession *)hn_activeSession {
    NSHTTPCookie *cookie = [self hn_sessionCookie];
    HNSession *session = nil;
    NSString *username = [cookie hn_username];
    NSString *sessionKey = [cookie hn_session];
    if (username.length && sessionKey.length) {
        HNUser *user = [[HNUser alloc] initWithUsername:username];
        session = [[HNSession alloc] initWithUser:user session:sessionKey];
    }
    return session;
}

- (NSArray *)hn_clearAllCookies {
    NSArray *cookies = self.cookies;
    for (NSHTTPCookie *cookie in cookies) {
        [self deleteCookie:cookie];
    }
    return cookies;
}

@end
