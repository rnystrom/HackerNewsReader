//
//  HNPostCell.h
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 4/7/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HNPostCell;

@protocol HNPostCellDelegate <NSObject>

- (void)postCellDidTapCommentButton:(HNPostCell *)postCell;

@end

@interface HNPostCell : UITableViewCell

@property (nonatomic, strong, readonly) UILabel *titleLabel;
@property (nonatomic, strong, readonly) UILabel *subtitleLabel;
@property (nonatomic, strong) id <HNPostCellDelegate> delegate;

- (void)setCommentCount:(NSUInteger)commentCount;

@end
