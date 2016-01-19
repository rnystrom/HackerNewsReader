//
//  HNComment.h
//  HackerNewsKit
//
//  Created by Ryan Nystrom on 4/8/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

@import Foundation;

#import "HNUser.h"
#import "HNCommentComponent.h"

NS_ASSUME_NONNULL_BEGIN

@interface HNComment : NSObject <NSCopying, NSCoding>

@property (nonatomic, assign, readonly) NSUInteger pk;
@property (nonatomic, strong, readonly) NSString *ageText;
@property (nonatomic, strong, readonly) HNUser *user;
@property (nonatomic, strong, readonly) NSArray *components;
@property (nonatomic, assign, readonly) NSUInteger indent;

- (instancetype)initWithUser:(HNUser *)user
                  components:(nullable NSArray *)components
                      indent:(NSUInteger)indent
                          pk:(NSUInteger)pk 
                     ageText:(nullable NSString *)ageText NS_DESIGNATED_INITIALIZER;

- (id)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
