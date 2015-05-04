//
//  HNComment.h
//  HackerNewsKit
//
//  Created by Ryan Nystrom on 4/8/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HNUser.h"
#import "HNCommentComponent.h"

@interface HNComment : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong, readonly) HNUser *user;
@property (nonatomic, strong, readonly) NSArray *components;
@property (nonatomic, assign, readonly) NSUInteger indent;

- (instancetype)initWithUser:(HNUser *)user components:(NSArray *)components indent:(NSUInteger)indent NS_DESIGNATED_INITIALIZER;

@end
