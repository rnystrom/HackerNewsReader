//
//  HNEmptyTableCell.m
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 4/9/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import "HNEmptyTableCell.h"

#import "UIColor+HackerNews.h"
#import "UIFont+HackerNews.h"

@implementation HNEmptyTableCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.textLabel.font = [UIFont titleFont];
        self.textLabel.textColor = [UIColor subtitleTextColor];
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.textLabel.numberOfLines = 1;
    }
    return self;
}

@end
