//
//  HNCommentComponent.h
//  HackerNewsKit
//
//  Created by Ryan Nystrom on 4/12/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, HNCommentType) {
    HNCommentTypeLink,
    HNCommentTypeCode,
    HNCommentTypeText,
    HNCommentTypeItalic,
    HNCommentRemoved
};

@interface HNCommentComponent : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong, readonly) NSString *text;
@property (nonatomic, assign, readonly) HNCommentType type;
@property (nonatomic, assign, readonly, getter=isNewline) BOOL newline;

- (instancetype)initWithText:(NSString *)text type:(HNCommentType)type newline:(BOOL)newline NS_DESIGNATED_INITIALIZER;

@end
