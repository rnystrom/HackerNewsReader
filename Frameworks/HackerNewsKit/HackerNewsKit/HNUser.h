//
//  HNUser.h
//  HackerNewsKit
//
//  Created by Ryan Nystrom on 4/5/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

@import Foundation;

@interface HNUser : NSObject <NSCoding, NSCopying>

@property (nonatomic, copy, readonly) NSString *username;

- (instancetype)initWithUsername:(NSString *)username NS_DESIGNATED_INITIALIZER;

@end
