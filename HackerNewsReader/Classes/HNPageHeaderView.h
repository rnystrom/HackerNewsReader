//
//  HNPageHeaderView.h
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 5/7/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HNPageHeaderView : UIView

- (void)setTitleText:(NSString *)titleText;
- (void)setSubtitleText:(NSString *)subtitleText;
- (void)setTextAttributedString:(NSAttributedString *)textAttributedString;

@end
