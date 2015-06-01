//
//  NSURL+HackerNews.h
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 5/8/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

@import Foundation;

@interface NSURL (HackerNews)

- (id)hn_valueForQueryParameter:(NSString *)parameter;

- (BOOL)isHackerNewsURL;

@end
