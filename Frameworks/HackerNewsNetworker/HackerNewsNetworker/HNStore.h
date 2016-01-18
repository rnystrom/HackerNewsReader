//
//  HNStore.h
//  HackerNewsNetworker
//
//  Created by Ryan Nystrom on 4/6/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface HNStore : NSObject

@property (nonatomic, strong, readonly) NSString *cachePath;

- (instancetype)initWithCacheName:(NSString *)cacheName NS_DESIGNATED_INITIALIZER;

- (nullable id <NSCoding>)fetchFromDisk;

- (BOOL)archiveToDisk:(id <NSCoding>)object;

- (id)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
