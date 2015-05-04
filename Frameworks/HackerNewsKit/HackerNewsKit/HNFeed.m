//
//  HNFeed.m
//  HackerNewsKit
//
//  Created by Ryan Nystrom on 4/5/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import "HNFeed.h"

static NSString * const kHNFeedItems = @"kHNFeedItems";
static NSString * const kHNFeedCreatedDate = @"kHNFeedCreatedDate";

@implementation HNFeed

#pragma mark - Init

- (instancetype)initWithItems:(NSArray *)items createdDate:(NSDate *)createdDate {
    if (self = [super init]) {
        _items = [[NSArray alloc] initWithArray:items copyItems:YES] ?: @[];
        _createdDate = createdDate ?: [NSDate date];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%p %@ - %zi items, created: %@>",self,NSStringFromClass(self.class),self.items.count,self.createdDate];
}


#pragma mark - Merging

- (instancetype)feedByMergingFeed:(HNFeed *)feed {
    HNFeed *newFeed = [self feedByAppendingItems:feed.items];
    NSDate *latestDate = [feed.createdDate laterDate:self.createdDate];
    newFeed->_createdDate = latestDate;
    return newFeed;
}

- (instancetype)feedByAppendingItems:(NSArray *)items {
    NSArray *mergedItems = [self.items arrayByAddingObjectsFromArray:items];
    NSArray *sortedItems = [mergedItems sortedArrayUsingSelector:@selector(compare:)];
    NSArray *copiedItems = [[NSArray alloc] initWithArray:sortedItems copyItems:YES];
    HNFeed *newFeed = [[HNFeed alloc] initWithItems:copiedItems createdDate:[self.createdDate copy]];
    return newFeed;
}


#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    NSArray *items = [aDecoder decodeObjectForKey:kHNFeedItems];
    NSDate *createdDate = [aDecoder decodeObjectForKey:kHNFeedCreatedDate];
    return [self initWithItems:items createdDate:createdDate];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_items forKey:kHNFeedItems];
    [aCoder encodeObject:_createdDate forKey:kHNFeedCreatedDate];
}


#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    HNFeed *copy = [[HNFeed allocWithZone:zone] init];
    copy->_items = [[NSArray allocWithZone:zone] initWithArray:self.items copyItems:YES];
    copy->_createdDate = [self.createdDate copyWithZone:zone];
    return copy;
}


#pragma mark - Comparison

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:HNFeed.class]) {
        HNFeed *comp = (HNFeed *)object;
        return [comp.items isEqual:self.items] && [comp.createdDate isEqualToDate:self.createdDate];
    }
    return NO;
}

- (NSUInteger)hash {
    return [self.items hash] ^ [self.createdDate hash];
}

@end
