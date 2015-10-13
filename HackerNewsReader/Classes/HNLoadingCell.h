//
//  HNLoadingCell.h
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 4/9/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface HNLoadingCell : UITableViewCell

@property (nonatomic, strong, readonly) UIActivityIndicatorView *activityIndicatorView;

@end

NS_ASSUME_NONNULL_END
