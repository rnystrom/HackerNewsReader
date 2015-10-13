//
//  HNPage.h
//  HackerNewsKit
//
//  Created by Ryan Nystrom on 5/7/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

@import Foundation;

#import "HNComment.h"
#import "HNCommentComponent.h"
#import "HNPost.h"

@interface HNPage : NSObject <NSCoding, NSCopying>

@property (nonatomic, copy, readonly) HNPost *post;
@property (nonatomic, copy, readonly) NSArray *comments;
@property (nonatomic, copy, readonly) NSArray *textComponents;

- (instancetype)initWithPost:(HNPost *)post comments:(NSArray *)comments textComponents:(NSArray *)textComponents NS_DESIGNATED_INITIALIZER;

- (id)init NS_UNAVAILABLE;

@end
