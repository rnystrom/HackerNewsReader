//
//  HNCommentCell.h
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 4/11/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@class HNCommentCell;

@protocol HNCommentCellDelegate <NSObject>

- (void)commentCell:(HNCommentCell *)commentCell didTapCommentAtPoint:(CGPoint)point;
- (void)commentCell:(HNCommentCell *)commentCell didLongPressAtPoint:(CGPoint)point;

@end

@interface HNCommentCell : UITableViewCell

+ (UIEdgeInsets)contentInsetsForIndentationLevel:(NSUInteger)indentationLevel indentationWidth:(CGFloat)indentationWidth;

@property (nonatomic, weak) id <HNCommentCellDelegate> delegate;

- (void)setCommentBitmap:(id)commentBitmap;

- (void)setCommentContentSize:(CGSize)commentContentSize
             indentationLevel:(NSUInteger)indentationLevel
             indentationWidth:(CGFloat)indentationWidth;

@end

NS_ASSUME_NONNULL_END
