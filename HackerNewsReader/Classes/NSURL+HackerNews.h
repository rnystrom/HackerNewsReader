//
//  NSURL+HackerNews.h
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 5/8/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface NSURL (HackerNews)

- (id)hn_valueForQueryParameter:(NSString *)parameter;

- (BOOL)isHackerNewsURL;

@end

NS_ASSUME_NONNULL_END
