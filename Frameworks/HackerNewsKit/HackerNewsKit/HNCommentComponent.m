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
static NSString * const kHNCommentComponentNewline = @"kHNCommentComponentNewline";

@implementation HNCommentComponent

- (instancetype)initWithText:(NSString *)text type:(HNCommentType)type newline:(BOOL)newline {
    if (self = [super init]) {
        _text = [text copy] ?: @"";
        _type = type;
        _newline = newline;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%p %@, text: %@, newline: %@>",self,NSStringFromClass(self.class),self.text,self.newline?@"YES":@"NO"];
}


#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    NSString *text = [aDecoder decodeObjectForKey:kHNCommentComponentText];
    HNCommentType type = [aDecoder decodeIntegerForKey:kHNCommentComponentType];
    BOOL newline = [aDecoder decodeBoolForKey:kHNCommentComponentNewline];
    return [self initWithText:text type:type newline:newline];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_text forKey:kHNCommentComponentText];
    [aCoder encodeInteger:_type forKey:kHNCommentComponentType];
    [aCoder encodeBool:_newline forKey:kHNCommentComponentNewline];
}


#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    HNCommentComponent *copy = [[HNCommentComponent allocWithZone:zone] init];
    copy->_text = [self.text copy];
    copy->_type = self.type;
    copy->_newline = self.newline;
    return copy;
}


#pragma mark - Comparison

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:HNCommentComponent.class]) {
        HNCommentComponent *comp = (HNCommentComponent *)object;
        return comp.type == self.type && [comp.text isEqualToString:self.text] && comp.isNewline == self.isNewline;
    }
    return NO;
}

- (NSUInteger)hash {
    return self.type ^ [self.text hash] ^ self.isNewline;
}

@end
