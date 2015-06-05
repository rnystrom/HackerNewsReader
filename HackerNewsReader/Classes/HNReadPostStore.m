//
//  HNReadPostStore.m
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 6/5/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import "HNReadPostStore.h"

#import <HackerNewsNetworker/HNStore.h>

@interface HNReadPostStore ()

@property (nonatomic, strong) HNStore *store;
@property (nonatomic, strong, readonly) NSString *storePath;
@property (nonatomic, strong) NSMutableIndexSet *indexSet;

@end

@implementation HNReadPostStore

- (instancetype)initWithStoreName:(NSString *)storeName {
    if (self = [super init]) {
        _store = [[HNStore alloc] initWithCacheName:storeName];
        _indexSet = [(NSIndexSet *)[_store fetchFromDisk] mutableCopy] ?: [[NSMutableIndexSet alloc] init];
    }
    return self;
}


#pragma mark - Public API

- (BOOL)hasReadPK:(NSInteger)pk {
    return [self.indexSet containsIndex:pk];
}

- (void)readPK:(NSInteger)pk {
    [self.indexSet addIndex:pk];
}

- (void)synchronize {
    NSIndexSet *pks = [self.indexSet copy];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.store archiveToDisk:pks];
    });
}

@end
