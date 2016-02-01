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
@property (nonatomic, strong, readonly) NSString *aboutText;
@property (nonatomic, strong, readonly) NSString *createdText;
@property (nonatomic, strong, readonly) NSNumber *karma;

- (instancetype)initWithUsername:(nullable NSString *)username
                       aboutText:(nullable NSString *)aboutText
                     createdText:(nullable NSString *)createdText
                           karma:(nullable NSNumber *)karma NS_DESIGNATED_INITIALIZER;

- (NSComparisonResult)compare:(HNUser *)object;

- (id)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
