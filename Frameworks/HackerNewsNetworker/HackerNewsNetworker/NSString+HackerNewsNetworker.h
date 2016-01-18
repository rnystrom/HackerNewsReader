//
//  NSString+HackerNewsNetworker.h
//  HackerNewsNetworker
//
//  Created by Ryan Nystrom on 1/16/16.
//  Copyright © 2016 Ryan Nystrom. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface NSString (HackerNewsNetworker)

- (NSDictionary *)hn_queryParameters;

@end

NS_ASSUME_NONNULL_END
