//
//  HNCommentButton.m
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 4/7/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import "HNCommentButton.h"

#import "UIColor+HackerNews.h"
#import "UIFont+HackerNews.h"

static CGFloat const kHNCommentButtonSpacing = 3.0;

@interface HNCommentButton ()

@property (strong, nonatomic, readonly) UILabel *commentLabel;
@property (strong, nonatomic, readonly) UIImageView *commentIconView;

@end

@implementation HNCommentButton

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];

        UIImage *image = [UIImage imageNamed:@"chat"];
        _commentIconView = [[UIImageView alloc] initWithImage:image];
        _commentIconView.tintColor = [UIColor hn_subtitleTextColor];
        _commentIconView.contentMode = UIViewContentModeCenter;
        _commentIconView.userInteractionEnabled = NO;
        [self addSubview:_commentIconView];

        CGRect iconFrame = _commentIconView.frame;
        CGFloat commentFontHeight = 12.0;
        CGFloat commentSpacing = 3.0;
        _commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, CGRectGetMaxY(iconFrame) + commentSpacing, CGRectGetWidth(iconFrame), commentFontHeight)];
        _commentLabel.font = [UIFont systemFontOfSize:commentFontHeight];
        _commentLabel.textColor = [UIColor hn_subtitleTextColor];
        _commentLabel.textAlignment = NSTextAlignmentCenter;
        _commentLabel.userInteractionEnabled = NO;
        [self addSubview:_commentLabel];
    }
    return self;
}


#pragma mark - Public API

- (void)setCommentText:(NSString *)commentText {
    self.commentLabel.text = commentText;
    [self setNeedsLayout];
}

- (void)setCommentHidden:(BOOL)commentHidden {
    self.commentLabel.hidden = commentHidden;
    [self setNeedsLayout];
}


#pragma mark - Layout

- (CGSize)sizeThatFits:(CGSize)size {
    CGRect iconBounds = self.commentIconView.bounds;
    return CGSizeMake(CGRectGetWidth(iconBounds), CGRectGetHeight(iconBounds) + self.commentLabel.font.pointSize + kHNCommentButtonSpacing);
}

- (void)layoutSubviews {
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    CGSize iconSize = self.commentIconView.bounds.size;
    CGFloat iconOffset = self.commentLabel.hidden ? 0.0 : iconSize.height / 4;
    self.commentIconView.frame = CGRectMake((width - iconSize.width) / 2,
                                            (height - iconSize.height) / 2 - iconOffset,
                                            iconSize.width,
                                            iconSize.height);

    if (!self.commentLabel.hidden) {
        [self.commentLabel sizeToFit];
        self.commentLabel.frame = CGRectMake(0.0,
                                             CGRectGetMaxY(self.commentIconView.frame) + kHNCommentButtonSpacing,
                                             width,
                                             CGRectGetHeight(self.commentLabel.bounds));
    }
}


#pragma mark - Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    self.commentIconView.tintColor = [UIColor hn_highlightedTintColor];
    self.commentLabel.textColor = [UIColor hn_highlightedTintColor];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    self.commentIconView.tintColor = [UIColor hn_subtitleTextColor];
    self.commentLabel.textColor = [UIColor hn_subtitleTextColor];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    self.commentIconView.tintColor = [UIColor hn_subtitleTextColor];
    self.commentLabel.textColor = [UIColor hn_subtitleTextColor];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    self.commentIconView.tintColor = [UIColor hn_subtitleTextColor];
    self.commentLabel.textColor = [UIColor hn_subtitleTextColor];
}


#pragma mark - Accessibility

- (BOOL)isAccessibilityElement {
    return YES;
}

- (UIAccessibilityTraits)accessibilityTraits {
    return UIAccessibilityTraitButton;
}

- (NSString *)accessibilityLabel {
    NSString *axFormatString = NSLocalizedString(@"%@ comments", @"The number of comments in a post");
    return [NSString stringWithFormat:axFormatString, self.commentLabel.text];
}

@end
