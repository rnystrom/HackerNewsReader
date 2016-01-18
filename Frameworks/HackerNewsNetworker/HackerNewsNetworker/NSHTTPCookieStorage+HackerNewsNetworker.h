//
//  NSHTTPCookieStorage+HackerNewsNetworker.h
//  HackerNewsNetworker
//
//  Created by Ryan Nystrom on 1/10/16.
//  Copyright © 2016 Ryan Nystrom. All rights reserved.
//

@import Foundation;

@class HNSession;

NS_ASSUME_NONNULL_BEGIN

@interface NSHTTPCookieStorage (HackerNewsNetworker)

- (nullable HNSession *)hn_activeSession;

- (nullable NSArray *)hn_clearAllCookies;

@end

NS_ASSUME_NONNULL_END
