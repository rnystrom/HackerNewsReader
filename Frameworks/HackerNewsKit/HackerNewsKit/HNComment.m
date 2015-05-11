//
//  HNComment.m
//  HackerNewsKit
//
//  Created by Ryan Nystrom on 4/8/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import "HNComment.h"

static NSString * const kHNCommentUser = @"kHNCommentUser";
static NSString * const kHNCommentCompents = @"kHNCommentCompents";
static NSString * const kHNCommentIndent = @"kHNCommentIndent";

@implementation HNComment

- (instancetype)initWithUser:(HNUser *)user components:(NSArray *)components indent:(NSUInteger)indent {
    if (self = [super init]) {
        NSAssert(user != nil, @"Cannot initialize a comment without a user");
        _user = [user copy];
        _components = [components copy];
        _indent = indent;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%p %@: %@ - %@, indent: %zi>", self, NSStringFromClass(self.class), self.user, self.components, self.indent];
}


#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    HNUser *user = [aDecoder decodeObjectForKey:kHNCommentUser];
    NSArray *components = [aDecoder decodeObjectForKey:kHNCommentCompents];
    NSUInteger indent = [aDecoder decodeIntegerForKey:kHNCommentIndent];
    return [self initWithUser:user components:components indent:indent];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_user forKey:kHNCommentUser];
    [aCoder encodeObject:_components forKey:kHNCommentCompents];
    [aCoder encodeInteger:_indent forKey:kHNCommentIndent];
}


#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    HNComment *copy = [[HNComment allocWithZone:zone] init];
    copy->_user = [self.user copyWithZone:zone];
    copy->_components = [[NSArray alloc] initWithArray:self.components copyItems:YES];
    copy->_indent = self.indent;
    return copy;
}


#pragma mark - Comparison

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:HNComment.class]) {
        HNComment *comp = (HNComment *)object;
        return comp.indent == self.indent && [comp.user isEqual:self.user] && [comp.components isEqual:self.components];
    }
    return NO;
}

- (NSUInteger)hash {
    return [self.components hash] ^ [self.user hash] ^ self.indent;
}

@end
