//
//  HNCommentHeaderCell.m
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 4/12/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import "HNCommentHeaderCell.h"

#import "UIColor+HackerNews.h"
#import "UIFont+HackerNews.h"

static CGFloat const kHNCommentHeaderPadding = 15.0;

@interface HNCommentHeaderCell ()

@property (nonatomic, strong, readonly) UILabel *collapsedLabel;

@end

@implementation HNCommentHeaderCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.clipsToBounds = YES;
        
        _usernameLabel = [[UILabel alloc] init];
        _usernameLabel.font = [UIFont subtitleFont];
        _usernameLabel.textColor = [UIColor subtitleTextColor];
        [self.contentView addSubview:_usernameLabel];

        _collapsedLabel = [[UILabel alloc] init];
        _collapsedLabel.textColor = [UIColor subtitleTextColor];
        _collapsedLabel.font = [UIFont subtitleFont];
        _collapsedLabel.text = @"\u2013";
        [self.contentView addSubview:_collapsedLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGRect bounds = self.contentView.bounds;
    CGRect usernameFrame = CGRectInset(bounds, self.indentationWidth * self.indentationLevel + kHNCommentHeaderPadding, 0.0);
    self.usernameLabel.frame = usernameFrame;

    [self.collapsedLabel sizeToFit];
    self.collapsedLabel.center = CGPointMake(CGRectGetWidth(bounds) - kHNCommentHeaderPadding - CGRectGetWidth(self.collapsedLabel.bounds) / 2, CGRectGetMidY(bounds));
}

- (void)setCollapsed:(BOOL)collapsed {
    if (_collapsed != collapsed) {
        _collapsed = collapsed;
        self.collapsedLabel.text = collapsed ? @"+" : @"\u2013";
    }
}

@end
