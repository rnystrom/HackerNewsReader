//
//  HNPage.m
//  HackerNewsKit
//
//  Created by Ryan Nystrom on 5/7/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import "HNPage.h"

static NSString * const kHNPagePost = @"kHNPagePost";
static NSString * const kHNPageComments = @"kHNPageComments";
static NSString * const kHNPageTextComponents = @"kHNPageTextComponents";

@implementation HNPage

- (instancetype)initWithPost:(HNPost *)post comments:(NSArray *)comments textComponents:(NSArray *)textComponents {
    if (self = [super init]) {
        _post = [post copy];
        _comments = [comments copy];
        _textComponents = [textComponents copy];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%p %@: %@, comments: %@, text: %@>",self, NSStringFromClass(self.class), self.post, self.comments, self.textComponents];
}


#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    HNPost *post = [aDecoder decodeObjectForKey:kHNPagePost];
    NSArray *comments = [aDecoder decodeObjectForKey:kHNPageComments];
    NSArray *textComponents = [aDecoder decodeObjectForKey:kHNPageTextComponents];
    return [self initWithPost:post comments:comments textComponents:textComponents];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_post forKey:kHNPagePost];
    [aCoder encodeObject:_comments forKey:kHNPageComments];
    [aCoder encodeObject:_textComponents forKey:kHNPageTextComponents];
}


#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    return [[HNPage allocWithZone:zone] initWithPost:self.post comments:self.comments textComponents:self.textComponents];
}


#pragma mark - Comparison

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:HNPage.class]) {
        HNPage *page = object;
        return [page.post isEqual:self.post] && [page.comments isEqualToArray:self.comments] && [page.textComponents isEqualToArray:self.textComponents];
    }
    return NO;
}

- (NSUInteger)hash {
    return [self.post hash] ^ [self.comments hash];
}

@end
