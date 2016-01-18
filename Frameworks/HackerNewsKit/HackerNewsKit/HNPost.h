//
//  HNPost.h
//  HackerNewsKit
//
//  Created by Ryan Nystrom on 4/5/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

@import Foundation;

extern NSUInteger const kHNPostPKIsLinkOnly;

NS_ASSUME_NONNULL_BEGIN

@interface HNPost : NSObject <NSCopying, NSCoding>

@property (nonatomic, strong, readonly) NSString *title;
@property (nonatomic, strong, readonly) NSString *ageText;
@property (nonatomic, strong, readonly) NSURL *URL;
@property (nonatomic, assign, readonly) NSUInteger score;
@property (nonatomic, assign, readonly) NSUInteger commentCount;
@property (nonatomic, assign, readonly) NSUInteger pk;
@property (nonatomic, assign, readonly) NSUInteger rank;

- (instancetype)initWithTitle:(nullable NSString *)title
                      ageText:(nullable NSString *)ageText
                          url:(nullable NSURL *)url
                        score:(NSUInteger)score
                 commentCount:(NSUInteger)commentCount
                           pk:(NSUInteger)pk
                         rank:(NSUInteger)rank NS_DESIGNATED_INITIALIZER;

- (id)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
