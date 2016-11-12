//
//  HNReadPostStore.h
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 6/5/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface HNReadPostStore : NSObject

- (instancetype)initWithStoreName:(NSString *)storeName;

- (BOOL)hasReadPK:(NSInteger)pk;
- (void)readPK:(NSInteger)pk;
- (void)synchronize;

@end

NS_ASSUME_NONNULL_END
