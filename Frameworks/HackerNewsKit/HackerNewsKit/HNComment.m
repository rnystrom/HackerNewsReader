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
static NSString * const kHNCommentPK = @"kHNCommentPK";
static NSString * const kHNCommentAgeText = @"kHNCommentAgeText";

@implementation HNComment

- (instancetype)initWithUser:(HNUser *)user
                  components:(NSArray *)components
                      indent:(NSUInteger)indent
                          pk:(NSUInteger)pk
                     ageText:(NSString *)ageText {
    NSParameterAssert(user != nil);
    if (self = [super init]) {
        _user = [user copy];
        _components = [components copy] ?: @[];
        _indent = indent;
        _pk = pk;
        _ageText = [ageText copy];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%p %@: %@ - %@, indent: %zi, age: %@, pk: %zi>",
            self, NSStringFromClass(self.class), self.user, self.components, self.indent, self.ageText, self.pk];
}


#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    HNUser *user = [aDecoder decodeObjectForKey:kHNCommentUser];
    NSArray *components = [aDecoder decodeObjectForKey:kHNCommentCompents];
    NSUInteger indent = [aDecoder decodeIntegerForKey:kHNCommentIndent];
    NSUInteger pk = [aDecoder decodeIntegerForKey:kHNCommentPK];
    NSString *ageText = [aDecoder decodeObjectForKey:kHNCommentAgeText];
    return [self initWithUser:user components:components indent:indent pk:pk ageText:ageText];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_user forKey:kHNCommentUser];
    [aCoder encodeObject:_components forKey:kHNCommentCompents];
    [aCoder encodeInteger:_indent forKey:kHNCommentIndent];
    [aCoder encodeObject:_ageText forKey:kHNCommentAgeText];
    [aCoder encodeInteger:_pk forKey:kHNCommentPK];
}


#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    return [[HNComment allocWithZone:zone] initWithUser:self.user
                                             components:self.components 
                                                 indent:self.indent
                                                     pk:self.pk
                                                ageText:self.ageText];
}


#pragma mark - Comparison

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    if ([object isKindOfClass:HNComment.class]) {
        HNComment *comp = (HNComment *)object;
        return comp.pk == self.pk;
    }
    return NO;
}

- (NSUInteger)hash {
    return self.pk;
}

- (NSComparisonResult)compare:(HNComment *)object {
    const NSUInteger pk = self.pk;
    const NSUInteger objPk = object.pk;
    if (pk > objPk) {
        return NSOrderedDescending;
    } else if (pk < objPk) {
        return NSOrderedAscending;
    } else {
        return NSOrderedSame;
    }
}

@end
