//
//  HNPost.h
//  FetchingHackerNews
//
//  Created by Ryan Nystrom on 4/5/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HNPost : NSObject <NSCoding, NSCopying>

@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, strong, readonly) NSURL *URL;
@property (nonatomic, assign, readonly) NSUInteger score;
@property (nonatomic, assign, readonly) NSUInteger commentCount;
@property (nonatomic, assign, readonly) NSUInteger pk;
@property (nonatomic, assign, readonly) NSUInteger rank;

- (instancetype)initWithTitle:(NSString *)title url:(NSURL *)url score:(NSUInteger)score commentCount:(NSUInteger)commentCount pk:(NSUInteger)pk rank:(NSUInteger)rank NS_DESIGNATED_INITIALIZER;

- (BOOL)isIdentical:(id)object;

@end
