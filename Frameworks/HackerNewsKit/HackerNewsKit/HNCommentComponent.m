//
//  HNCommentComponent.m
//  HackerNewsKit
//
//  Created by Ryan Nystrom on 4/12/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import "HNCommentComponent.h"

static NSString * const kHNCommentComponentText = @"kHNCommentComponentText";
static NSString * const kHNCommentComponentType = @"kHNCommentComponentType";

@implementation HNCommentComponent

+ (instancetype)newlineComponent {
    return [[self alloc] initWithText:@"" type:HNCommentNewline];
}

- (instancetype)initWithText:(NSString *)text type:(HNCommentType)type {
    if (self = [super init]) {
        _text = [text copy] ?: @"";
        _type = type;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%p %@, text: %@>",self,NSStringFromClass(self.class),self.text];
}


#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    NSString *text = [aDecoder decodeObjectForKey:kHNCommentComponentText];
    HNCommentType type = [aDecoder decodeIntegerForKey:kHNCommentComponentType];
    return [self initWithText:text type:type];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_text forKey:kHNCommentComponentText];
    [aCoder encodeInteger:_type forKey:kHNCommentComponentType];
}


#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    return [[HNCommentComponent allocWithZone:zone] initWithText:self.text type:self.type];
}


#pragma mark - Comparison

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:HNCommentComponent.class]) {
        HNCommentComponent *comp = (HNCommentComponent *)object;
        return comp.type == self.type && [comp.text isEqualToString:self.text];
    }
    return NO;
}

- (NSUInteger)hash {
    return self.type ^ [self.text hash];
}

@end
