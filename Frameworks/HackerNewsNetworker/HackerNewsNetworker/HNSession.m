//
//  HNSession.m
//  HackerNewsNetworker
//
//  Created by Ryan Nystrom on 1/10/16.
//  Copyright © 2016 Ryan Nystrom. All rights reserved.
//

#import "HNSession.h"

#import "NSHTTPCookieStorage+HackerNewsNetworker.h"

static NSString *const kHNSessionUserKey = @"kHNSessionUserKey";
static NSString *const kHNSessionSessionKey = @"kHNSessionSessionKey";

@implementation HNSession

+ (HNSession *)activeSession {
    return [[NSHTTPCookieStorage sharedHTTPCookieStorage] hn_activeSession];
}

- (instancetype)initWithUser:(HNUser *)user session:(NSString *)session {
    NSParameterAssert(user != nil);
    NSParameterAssert(session != nil);
    if (self = [super init]) {
        _user = user;
        _session = [session copy];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    HNUser *user = [aDecoder decodeObjectForKey:kHNSessionUserKey];
    NSString *session = [aDecoder decodeObjectForKey:kHNSessionSessionKey];
    return [self initWithUser:user session:session];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_user forKey:kHNSessionUserKey];
    [aCoder encodeObject:_session forKey:kHNSessionSessionKey];
}

@end
