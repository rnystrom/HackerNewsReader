//
//  NSHTTPCookieStorage+HackerNewsNetworker.h
//  HackerNewsNetworker
//
//  Created by Ryan Nystrom on 1/10/16.
//  Copyright © 2016 Ryan Nystrom. All rights reserved.
//

@import Foundation;

@class HNSession;

@interface NSHTTPCookieStorage (HackerNewsNetworker)

- (HNSession *)hn_activeSession;

- (NSArray *)hn_clearAllCookies;

@end
