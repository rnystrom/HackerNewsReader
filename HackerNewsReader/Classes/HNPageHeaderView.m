//
//  HNPageHeaderView.m
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 5/7/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import "HNPageHeaderView.h"

#import "UIColor+HackerNews.h"
#import "UIFont+HackerNews.h"

static UIEdgeInsets const kHNPageHeaderInsets = (UIEdgeInsets){8.0, 15.0, 8.0, 15.0};
static CGFloat const kHNPageHeaderLabelSpacing = 5.0;

@interface HNPageHeaderView ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) CALayer *borderLayer;

@end

@implementation HNPageHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.numberOfLines = 0;
        _titleLabel.font = [UIFont pageTitleFont];
        _titleLabel.textColor = [UIColor titleTextColor];
        _titleLabel.backgroundColor = self.backgroundColor;
        [self addSubview:_titleLabel];

        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.font = [UIFont subtitleFont];
        _subtitleLabel.textColor = [UIColor subtitleTextColor];
        _subtitleLabel.backgroundColor = self.backgroundColor;
        [self addSubview:_subtitleLabel];

        _textLabel = [[UILabel alloc] init];
        _textLabel.font = [UIFont titleFont];
        _textLabel.textColor = [UIColor titleTextColor];
        _textLabel.numberOfLines = 0;
        _textLabel.backgroundColor = self.backgroundColor;
        [self addSubview:_textLabel];

//        _borderLayer = [CALayer layer];
//        _borderLayer.backgroundColor = [UIColor colorWithRed:0.783922 green:0.780392 blue:0.8 alpha:1.0].CGColor;
//        [self.layer addSublayer:_borderLayer];
    }
    return self;
}


#pragma mark - Public API

- (void)setTitleText:(NSString *)titleText {
    self.titleLabel.text = titleText;
}

- (void)setSubtitleText:(NSString *)subtitleText {
    self.subtitleLabel.text = subtitleText;
}

- (void)setTextAttributedString:(NSAttributedString *)textAttributedString {
    self.textLabel.attributedText = textAttributedString;
}


#pragma mark - Layout

- (CGSize)sizeThatFits:(CGSize)size {
    CGRect inset = UIEdgeInsetsInsetRect((CGRect){CGPointZero, size}, kHNPageHeaderInsets);
    CGSize titleSize = [self.titleLabel sizeThatFits:inset.size];
    CGSize subtitleSize = [self.subtitleLabel sizeThatFits:inset.size];
    CGFloat textHeight = 0.0;
    if (self.textLabel.text.length) {
        CGSize textSize = [self.textLabel sizeThatFits:inset.size];
        textHeight += kHNPageHeaderLabelSpacing + textSize.height;
    }
    return CGSizeMake(size.width, kHNPageHeaderInsets.top + titleSize.height + kHNPageHeaderLabelSpacing + subtitleSize.height + textHeight + kHNPageHeaderInsets.bottom);
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGRect inset = UIEdgeInsetsInsetRect(self.bounds, kHNPageHeaderInsets);
    CGSize titleSize = [self.titleLabel sizeThatFits:inset.size];
    self.titleLabel.frame = CGRectMake(kHNPageHeaderInsets.left, kHNPageHeaderInsets.top, titleSize.width, titleSize.height);

    CGSize subtitleSize = [self.subtitleLabel sizeThatFits:inset.size];
    self.subtitleLabel.frame = CGRectMake(kHNPageHeaderInsets.left, CGRectGetMaxY(self.titleLabel.frame) + kHNPageHeaderLabelSpacing, subtitleSize.width, subtitleSize.height);

    if (self.textLabel.text) {
        CGSize textSize = [self.textLabel sizeThatFits:inset.size];
        self.textLabel.frame = CGRectMake(kHNPageHeaderInsets.left, CGRectGetMaxY(self.subtitleLabel.frame) + kHNPageHeaderLabelSpacing, textSize.width, textSize.height);
    }

    CGFloat separatorHeight = 1.0 / [UIScreen mainScreen].scale;
    self.borderLayer.frame = CGRectMake(kHNPageHeaderInsets.left, CGRectGetHeight(self.bounds) - separatorHeight, CGRectGetWidth(self.bounds), separatorHeight);
}

@end
