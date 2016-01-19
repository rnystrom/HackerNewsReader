//
//  HNUser.m
//  HackerNewsKit
//
//  Created by Ryan Nystrom on 4/5/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import "HNUser.h"

static NSString * const kHNUserUsername = @"kHNUserUsername";
static NSString * const kHNUserAboutText = @"kHNUserAboutText";
static NSString * const kHNUserCreatedText = @"kHNUserCreatedText";
static NSString * const kHNUserKarma = @"kHNUserKarma";

@implementation HNUser

- (instancetype)initWithUsername:(NSString *)username
                       aboutText:(nullable NSString *)aboutText
                     createdText:(nullable NSString *)createdText
                           karma:(nullable NSNumber *)karma {
    NSParameterAssert(username != nil);
    if (self = [super init]) {
        _username = [username copy];
        _aboutText = [aboutText copy];
        _createdText = [createdText copy];
        _karma = [karma copy];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%p %@ - %@>", self, NSStringFromClass(self.class), self.username];
}


#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    NSString *username = [aDecoder decodeObjectForKey:kHNUserUsername];
    NSString *aboutText = [aDecoder decodeObjectForKey:kHNUserAboutText];
    NSString *createdText = [aDecoder decodeObjectForKey:kHNUserCreatedText];
    NSNumber *karma = [aDecoder decodeObjectForKey:kHNUserKarma];
    return [self initWithUsername:username aboutText:aboutText createdText:createdText karma:karma];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_username forKey:kHNUserUsername];
    [aCoder encodeObject:_aboutText forKey:kHNUserAboutText];
    [aCoder encodeObject:_createdText forKey:kHNUserCreatedText];
    [aCoder encodeObject:_karma forKey:kHNUserKarma];
}


#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    return [[HNUser allocWithZone:zone] initWithUsername:self.username
                                               aboutText:self.aboutText
                                             createdText:self.createdText
                                                   karma:self.karma];
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
