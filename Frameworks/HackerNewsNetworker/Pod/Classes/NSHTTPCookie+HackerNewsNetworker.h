//
//  NSHTTPCookie+HackerNewsNetworker.h
//  HackerNewsNetworker
//
//  Created by Ryan Nystrom on 1/10/16.
//  Copyright © 2016 Ryan Nystrom. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface NSHTTPCookie (HackerNewsNetworker)

- (nullable NSArray *)hn_components;

- (nullable NSString *)hn_username;

- (nullable NSString *)hn_session;

@end

NS_ASSUME_NONNULL_END
