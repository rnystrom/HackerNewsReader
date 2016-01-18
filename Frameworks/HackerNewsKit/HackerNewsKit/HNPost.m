//
//  HNPost.m
//  HackerNewsKit
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
static NSString * const kHNPostAgeText = @"kHNPostAgeText";

NSUInteger const kHNPostPKIsLinkOnly = 0;

@implementation HNPost

- (instancetype)initWithTitle:(NSString *)title
                      ageText:(NSString *)ageText
                          url:(NSURL *)url
                        score:(NSUInteger)score
                 commentCount:(NSUInteger)commentCount
                           pk:(NSUInteger)pk
                         rank:(NSUInteger)rank {
    if (self = [super init]) {
        _title = [title copy] ?: @"";
        _URL = url ?: [NSURL new];
        _score = score;
        _commentCount = commentCount;
        _pk = pk;
        _rank = rank;
        _ageText = [ageText copy];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%p %@; title: %@, pk: %zi, score: %zi, %zi comments>",self, NSStringFromClass(self.class), self.title, self.pk, self.score, self.commentCount];
}


#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    NSString *title = [aDecoder decodeObjectForKey:kHNPostTitle];
    NSURL *URL = [aDecoder decodeObjectForKey:kHNPostURL];
    NSUInteger score = [aDecoder decodeIntegerForKey:kHNPostScore];
    NSUInteger commentCount = [aDecoder decodeIntegerForKey:kHNPostCommentCount];
    NSUInteger pk = [aDecoder decodeIntegerForKey:kHNPostPK];
    NSUInteger rank = [aDecoder decodeIntegerForKey:kHNPostRank];
    NSString *ageText = [aDecoder decodeObjectForKey:kHNPostAgeText];
    return [self initWithTitle:title ageText:ageText url:URL score:score commentCount:commentCount pk:pk rank:rank];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_title forKey:kHNPostTitle];
    [aCoder encodeObject:_URL forKey:kHNPostURL];
    [aCoder encodeInteger:_score forKey:kHNPostScore];
    [aCoder encodeInteger:_commentCount forKey:kHNPostCommentCount];
    [aCoder encodeInteger:_pk forKey:kHNPostPK];
    [aCoder encodeInteger:_rank forKey:kHNPostRank];
    [aCoder encodeObject:_ageText forKey:kHNPostAgeText];
}


#pragma mark - Comparison

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    if ([object isKindOfClass:HNPost.class]) {
        HNPost *comp = (HNPost *)object;
        return comp.pk == self.pk;
    }
    return NO;
}

- (NSComparisonResult)compare:(HNPost *)object {
    const NSUInteger rank = self.rank;
    const NSUInteger objRank = object.rank;
    if (rank > objRank) {
        return NSOrderedDescending;
    } else if (rank < objRank) {
        return NSOrderedAscending;
    } else {
        return NSOrderedSame;
    }
}

- (NSUInteger)hash {
    return self.pk ^ self.score ^ self.commentCount ^ [self.URL hash] ^ [self.ageText hash];
}


#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    return [[HNPost allocWithZone:zone] initWithTitle:self.title
                                              ageText:self.ageText
                                                  url:self.URL
                                                score:self.score
                                         commentCount:self.commentCount
                                                   pk:self.pk
                                                 rank:self.rank];
}

@end
