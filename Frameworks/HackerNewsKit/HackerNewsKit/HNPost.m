//
//  HNPost.m
//  FetchingHackerNews
//
//  Created by Ryan Nystrom on 4/5/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import "HNPost.h"

static NSString * const kHNPostTitle = @"kHNPostTitle";
static NSString * const kHNPostURL = @"kHNPostURL";
static NSString * const kHNPostScore = @"kHNPostScore";
static NSString * const kHNPostCommentCount = @"kHNPostCommentCount";
static NSString * const kHNPostPK = @"kHNPostPK";
static NSString * const kHNPostRank = @"kHNPostRank";

@implementation HNPost

- (instancetype)initWithTitle:(NSString *)title url:(NSURL *)url score:(NSUInteger)score commentCount:(NSUInteger)commentCount pk:(NSUInteger)pk rank:(NSUInteger)rank {
    if (self = [super init]) {
        _title = [title copy] ?: @"";
        _URL = url ?: [[NSURL alloc] init];
        _score = score;
        _commentCount = commentCount;
        _pk = pk;
        _rank = rank;
    }
    return self;
}

- (NSString *)description {
    NSString *info = [@{
                        @"title": self.title,
                        @"link": self.URL,
                        @"score": @(self.score),
                        @"comments": @(self.commentCount),
                        @"pk": @(self.pk),
                        @"rank": @(self.rank)
                        } description];
    return [NSString stringWithFormat:@"<%p %@ - %@>",self,NSStringFromClass(self.class),info];
}


#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    NSString *title = [aDecoder decodeObjectForKey:kHNPostTitle];
    NSURL *URL = [aDecoder decodeObjectForKey:kHNPostURL];
    NSUInteger score = [aDecoder decodeIntegerForKey:kHNPostScore];
    NSUInteger commentCount = [aDecoder decodeIntegerForKey:kHNPostCommentCount];
    NSUInteger pk = [aDecoder decodeIntegerForKey:kHNPostPK];
    NSUInteger rank = [aDecoder decodeIntegerForKey:kHNPostRank];
    return [self initWithTitle:title url:URL score:score commentCount:commentCount pk:pk rank:rank];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_title forKey:kHNPostTitle];
    [aCoder encodeObject:_URL forKey:kHNPostURL];
    [aCoder encodeInteger:_score forKey:kHNPostScore];
    [aCoder encodeInteger:_commentCount forKey:kHNPostCommentCount];
    [aCoder encodeInteger:_pk forKey:kHNPostPK];
    [aCoder encodeInteger:_rank forKey:kHNPostRank];
}


#pragma mark - Comparison

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:HNPost.class]) {
        HNPost *comp = (HNPost *)object;
        return comp.pk == self.pk;
    }
    return NO;
}

- (BOOL)isIdentical:(id)object {
    if ([object isKindOfClass:HNPost.class]) {
        HNPost *comp = (HNPost *)object;
        return comp.pk == self.pk && comp.commentCount == self.commentCount && comp.rank == self.rank && comp.score == self.score && [comp.title isEqualToString:self.title] && [comp.URL isEqual:self.URL];
    }
    return NO;
}

- (NSComparisonResult)compare:(HNPost *)object {
    if (self.rank > object.rank) {
        return NSOrderedDescending;
    } else if (self.rank < object.rank) {
        return NSOrderedAscending;
    } else {
        return NSOrderedSame;
    }
}

- (NSUInteger)hash {
    return self.pk ^ self.score ^ self.commentCount ^ [self.URL hash];
}


#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    HNPost *copy = [[HNPost allocWithZone:zone] init];
    copy->_title = [self.title copyWithZone:zone];
    copy->_URL = [self.URL copyWithZone:zone];
    copy->_score = self.score;
    copy->_commentCount = self.commentCount;
    copy->_pk = self.pk;
    copy->_rank = self.rank;
    return copy;
}

@end
