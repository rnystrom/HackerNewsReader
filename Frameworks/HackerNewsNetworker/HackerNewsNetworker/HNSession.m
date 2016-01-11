//
//  HNSession.m
//  HackerNewsNetworker
//
//  Created by Ryan Nystrom on 1/10/16.
//  Copyright © 2016 Ryan Nystrom. All rights reserved.
//

#import "HNSession.h"

static NSString *const kHNSessionUsernameKey = @"kHNSessionUsernameKey";
static NSString *const kHNSessionSessionKey = @"kHNSessionSessionKey";

@implementation HNSession

- (instancetype)initWithUsername:(NSString *)username session:(NSString *)session {
    if (self = [super init]) {
        _username = [username copy];
        _session = [session copy];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    NSString *username = [aDecoder decodeObjectForKey:kHNSessionSessionKey];
    NSString *session = [aDecoder decodeObjectForKey:kHNSessionUsernameKey];
    return [self initWithUsername:username session:session];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_username forKey:kHNSessionUsernameKey];
    [aCoder encodeObject:_session forKey:kHNSessionSessionKey];
}

@end
