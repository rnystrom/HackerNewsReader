//
//  HNStore.h
//  HackerNewsNetworker
//
//  Created by Ryan Nystrom on 4/6/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HNStore : NSObject

@property (nonatomic, strong, readonly) NSString *cachePath;

- (instancetype)initWithCacheName:(NSString *)cacheName NS_DESIGNATED_INITIALIZER;

- (id <NSCoding>)fetchFromDisk;

- (BOOL)archiveToDisk:(id <NSCoding>)object;

@end
