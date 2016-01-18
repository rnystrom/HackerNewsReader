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

NS_ASSUME_NONNULL_BEGIN

@interface HNPage : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong, readonly) HNPost *post;
@property (nonatomic, strong, readonly) NSArray *comments;
@property (nonatomic, strong, readonly) NSArray *textComponents;

- (instancetype)initWithPost:(HNPost *)post
                    comments:(nullable NSArray *)comments
              textComponents:(nullable NSArray *)textComponents NS_DESIGNATED_INITIALIZER;

- (id)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
