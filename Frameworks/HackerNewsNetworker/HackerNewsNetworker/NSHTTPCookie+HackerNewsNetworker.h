//
//  NSHTTPCookie+HackerNewsNetworker.h
//  HackerNewsNetworker
//
//  Created by Ryan Nystrom on 1/10/16.
//  Copyright © 2016 Ryan Nystrom. All rights reserved.
//

@import Foundation;

@interface NSHTTPCookie (HackerNewsNetworker)

- (NSArray *)hackerNewsComponents;

- (NSString *)hackerNewsUsername;

- (NSString *)hackerNewsSession;

@end
