//
//  HNUser.h
//  HackerNewsKit
//
//  Created by Ryan Nystrom on 4/5/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface HNUser : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong, readonly) NSString *username;

- (instancetype)initWithUsername:(NSString *)username NS_DESIGNATED_INITIALIZER;

- (NSComparisonResult)compare:(HNUser *)object;

- (id)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
