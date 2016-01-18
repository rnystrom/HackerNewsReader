//
//  HNUser.m
//  HackerNewsKit
//
//  Created by Ryan Nystrom on 4/5/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import "HNUser.h"

static NSString * const kHNUserUsername = @"kHNUserUsername";

@implementation HNUser

- (instancetype)initWithUsername:(NSString *)username {
    if (self = [super init]) {
        _username = [username copy] ?: @"";
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%p %@ - %@>", self, NSStringFromClass(self.class), self.username];
}


#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    NSString *username = [aDecoder decodeObjectForKey:kHNUserUsername];
    return [self initWithUsername:username];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_username forKey:kHNUserUsername];
}


#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    return [[HNUser allocWithZone:zone] initWithUsername:self.username];
}


#pragma mark - Comparison

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    if ([object isKindOfClass:HNUser.class]) {
        return [[((HNUser *)object) username] isEqualToString:self.username];
    }
    return NO;
}

- (NSComparisonResult)compare:(HNUser *)object {
    return [self.username compare:object.username];
}

- (NSUInteger)hash {
    return [self.username hash];
}

@end
