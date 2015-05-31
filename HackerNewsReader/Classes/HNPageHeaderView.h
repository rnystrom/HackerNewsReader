//
//  HNPageHeaderView.h
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 5/7/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

@import UIKit;

@class HNPageHeaderView;

@protocol HNPageHeaderViewDelegate <NSObject>

@optional
- (void)pageHeaderDidTapTitle:(HNPageHeaderView *)pageHeader;
- (void)pageHeader:(HNPageHeaderView *)pageHeader didTapText:(NSAttributedString *)text characterAtIndex:(NSUInteger)index;
- (void)pageHeader:(HNPageHeaderView *)pageHeader didLongPressAtPoint:(CGPoint)point;

@end

@interface HNPageHeaderView : UIView

@property (nonatomic, weak) id <HNPageHeaderViewDelegate> delegate;

- (void)setTitleText:(NSString *)titleText;
- (void)setSubtitleText:(NSString *)subtitleText;
- (void)setTextAttributedString:(NSAttributedString *)textAttributedString;

@end
