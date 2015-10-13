//
//  HNTextItem.h
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 4/26/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface HNTextRenderer : NSObject

@property (nonatomic, strong, readonly) NSAttributedString *attributedString;
@property (nonatomic, assign, readonly) CGFloat width;
@property (atomic, assign, readonly) CGFloat height;
@property (atomic, strong, readonly) id contents;

- (instancetype)initWithAttributedString:(NSAttributedString *)attributedString width:(CGFloat)width NS_DESIGNATED_INITIALIZER;

- (NSDictionary *)attributesAtPoint:(CGPoint)point;

- (void)invalidate;

- (id)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
