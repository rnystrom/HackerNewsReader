//
//  HNCommentHeaderCell.h
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 4/12/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

@import UIKit;

@interface HNCommentHeaderCell : UITableViewCell

@property (nonatomic, strong, readonly) UILabel *titleLabel;
@property (nonatomic, assign, getter=isCollapsed) BOOL collapsed;

@end
