//
//  HNPage+Links.h
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 5/13/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

@import Foundation;

#import <HackerNewsKit/HackerNewsKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HNPage (Links)

- (NSURL *)permalink;

@end

NS_ASSUME_NONNULL_END
