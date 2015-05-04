//
//  HNCommentCell.h
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 4/11/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HNCommentCell;

@protocol HNCommentCellDelegate <NSObject>

@optional
- (void)commentCell:(HNCommentCell *)commentCell didTapCommentAtPoint:(CGPoint)point;
- (void)commentCell:(HNCommentCell *)commentCell didLongPressCommentAtPoint:(CGPoint)point;

@end

@interface HNCommentCell : UITableViewCell

+ (UIEdgeInsets)contentInsetsForIndentationLevel:(NSUInteger)indentationLevel indentationWidth:(CGFloat)indentationWidth;

@property (nonatomic, weak) id <HNCommentCellDelegate> delegate;
@property (nonatomic, strong, readonly) UIView *commentContentView;

//- (void)setAttributedString:(NSAttributedString *)attributedString;

@end
