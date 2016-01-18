//
//  HNSession.h
//  HackerNewsNetworker
//
//  Created by Ryan Nystrom on 1/10/16.
//  Copyright © 2016 Ryan Nystrom. All rights reserved.
//

@import Foundation;

@class HNUser;

NS_ASSUME_NONNULL_BEGIN

@interface HNSession : NSObject <NSCoding>

+ (HNSession *)activeSession;

@property (nonatomic, strong, readonly) HNUser *user;
@property (nonatomic, strong, readonly) NSString *session;

- (instancetype)initWithUser:(HNUser *)user session:(NSString *)session NS_DESIGNATED_INITIALIZER;

- (id)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
