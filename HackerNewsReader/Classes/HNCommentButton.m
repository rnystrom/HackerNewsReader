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

@property (strong, nonatomic, readwrite) UILabel *commentLabel;
@property (strong, nonatomic, readwrite) UIImageView *commentIconView;

@end

@implementation HNCommentButton

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];

        UIImage *image = [UIImage imageNamed:@"chat"];
        _commentIconView = [[UIImageView alloc] initWithImage:image];
        _commentIconView.tintColor = [UIColor subtitleTextColor];
        _commentIconView.contentMode = UIViewContentModeCenter;
        [self addSubview:_commentIconView];

        CGRect iconFrame = _commentIconView.frame;
        CGFloat commentFontHeight = 12.0;
        CGFloat commentSpacing = 3.0;
        _commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, CGRectGetMaxY(iconFrame) + commentSpacing, CGRectGetWidth(iconFrame), commentFontHeight)];
        _commentLabel.font = [UIFont systemFontOfSize:commentFontHeight];
        _commentLabel.textColor = [UIColor subtitleTextColor];
        _commentLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_commentLabel];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGRect iconBounds = self.commentIconView.bounds;
    return CGSizeMake(CGRectGetWidth(iconBounds), CGRectGetHeight(iconBounds) + self.commentLabel.font.pointSize + kHNCommentButtonSpacing);
}

- (void)layoutSubviews {
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    CGSize iconSize = self.commentIconView.bounds.size;
    self.commentIconView.frame = CGRectMake((width - iconSize.width) / 2,
                                            (height - iconSize.height) / 2 - iconSize.height / 4,
                                            iconSize.width,
                                            iconSize.height);

    [self.commentLabel sizeToFit];
    self.commentLabel.frame = CGRectMake(0.0,
                                         CGRectGetMaxY(self.commentIconView.frame) + kHNCommentButtonSpacing,
                                         width,
                                         CGRectGetHeight(self.commentLabel.bounds));
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    self.commentIconView.tintColor = [UIColor highlightedTintColor];
    self.commentLabel.textColor = [UIColor highlightedTintColor];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    self.commentIconView.tintColor = [UIColor subtitleTextColor];
    self.commentLabel.textColor = [UIColor subtitleTextColor];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    self.commentIconView.tintColor = [UIColor subtitleTextColor];
    self.commentLabel.textColor = [UIColor subtitleTextColor];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    self.commentIconView.tintColor = [UIColor subtitleTextColor];
    self.commentLabel.textColor = [UIColor subtitleTextColor];
}

@end
