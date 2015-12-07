//
//  HNPostCell.m
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 4/7/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import "HNPostCell.h"

#import "HNCommentButton.h"
#import "UIColor+HackerNews.h"
#import "UIFont+HackerNews.h"

static UIEdgeInsets const kHNPostCellInset = (UIEdgeInsets) {8.0, 15.0, 8.0, 0.0};
static CGFloat const kHNPostCellLabelSpacing = 5.0;
static CGFloat const kHNPostCellImageSpacing = 10.0;
static CGFloat const kHNCommentButtonWidth = 44.0;

@interface HNPostCell ()


@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (strong, nonatomic, readwrite) HNCommentButton *commentButton;
@property (nonatomic, assign) BOOL commentCountHidden;

@end

@implementation HNPostCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.clipsToBounds = YES;
        self.contentView.backgroundColor = [UIColor whiteColor];

        _titleLabel = [[UILabel alloc] init];
        _titleLabel.numberOfLines = 0;
        _titleLabel.font = [UIFont hn_titleFont];
        _titleLabel.textColor = [UIColor hn_titleTextColor];
        _titleLabel.backgroundColor = self.contentView.backgroundColor;
        [self.contentView addSubview:_titleLabel];

        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.font = [UIFont hn_subtitleFont];
        _subtitleLabel.textColor = [UIColor hn_subtitleTextColor];
        _subtitleLabel.backgroundColor = self.contentView.backgroundColor;
        [self.contentView addSubview:_subtitleLabel];

        _commentButton = [[HNCommentButton alloc] init];
        [_commentButton addTarget:self action:@selector(didTapCommentButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_commentButton];
    }
    return self;
}


#pragma mark - Public API

- (void)setCommentCount:(NSUInteger)commentCount {
    [self.commentButton setCommentText:[NSString stringWithFormat:@"%zi",commentCount]];
}

- (void)setRead:(BOOL)read {
    _read = read;
    _titleLabel.textColor = read ? [UIColor hn_subtitleTextColor] : [UIColor hn_titleTextColor];
}

- (void)setCommentButtonHidden:(BOOL)commentButtonHidden {
    self.commentButton.hidden = commentButtonHidden;
}

- (void)setCommentCountHidden:(BOOL)commentCountHidden {
    if (_commentCountHidden != commentCountHidden) {
        [self.commentButton setCommentHidden:commentCountHidden];
    }
}

- (void)setTitle:(NSString *)title {
    self.titleLabel.text = title;
    [self configureAccessibility];
}

- (void)setSubtitle:(NSString *)subtitle {
    self.subtitleLabel.text = subtitle;
    [self configureAccessibility];
}


#pragma mark - Private API

- (void)configureAccessibility {
    NSString *title = self.titleLabel.text;
    NSString *subtitle = self.subtitleLabel.text;
    if (title.length && subtitle.length) {
        self.titleLabel.accessibilityLabel = [NSString stringWithFormat:@"%@, %@", title, subtitle];
    } else {
        self.titleLabel.accessibilityLabel = title.length ? title : subtitle;
    }
}


#pragma mark - Layout

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat subtitleHeight = self.subtitleLabel.text.length ? self.subtitleLabel.font.pointSize + 4.0 + kHNPostCellLabelSpacing: 0.0;
    CGFloat height = [self titleSizeForWidth:size.width].height + kHNPostCellInset.top + kHNPostCellInset.bottom + subtitleHeight;
    return CGSizeMake(size.width, height);
}

- (CGSize)titleSizeForWidth:(CGFloat)width {
    static NSMutableDictionary *sizeCache;

    NSAssert([NSThread isMainThread], @"Cannot size cells off of the main thread");

    if (!sizeCache) {
        sizeCache = [[NSMutableDictionary alloc] init];
    }

    id key = [NSString stringWithFormat:@"%f-%@",width,self.titleLabel.text]; // only value that effects the size
    if (!key) {
        return CGSizeZero;
    }

    NSValue *cachedSize = sizeCache[key];

    if (cachedSize) {
        return [cachedSize CGSizeValue];
    }

    CGSize size = [self.titleLabel sizeThatFits:CGSizeMake(width - kHNPostCellInset.left - kHNPostCellInset.right - kHNCommentButtonWidth - kHNPostCellImageSpacing, CGFLOAT_MAX)];
    sizeCache[key] = [NSValue valueWithCGSize:size];
    return size;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGRect bounds = self.contentView.bounds;
    CGFloat width = CGRectGetWidth(bounds);

    self.commentButton.frame = CGRectMake(width - kHNCommentButtonWidth, 0.0, kHNCommentButtonWidth, CGRectGetHeight(bounds));

    CGSize titleSize = [self titleSizeForWidth:width];
    self.titleLabel.frame = (CGRect){CGPointMake(kHNPostCellInset.left, kHNPostCellInset.top), titleSize};

    CGFloat subtitleTop = CGRectGetMaxY(self.titleLabel.frame) + kHNPostCellLabelSpacing;

    [self.subtitleLabel sizeToFit];
    self.subtitleLabel.frame = (CGRect){CGPointMake(kHNPostCellInset.left, subtitleTop), self.subtitleLabel.bounds.size};

    CGRect axFrame, remainderFrame;
    CGRectDivide(self.accessibilityFrame, &remainderFrame, &axFrame, CGRectGetWidth(self.commentButton.bounds), CGRectMaxXEdge);
    self.titleLabel.accessibilityFrame = axFrame;
}


#pragma mark - Touches

- (void)didTapCommentButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(postCellDidTapCommentButton:)]) {
        [self.delegate postCellDidTapCommentButton:self];
    }
}


#pragma mark - Accessibility

- (BOOL)isAccessibilityElement {
    return NO;
}

- (NSArray *)accessibilityElements {
    return @[self.titleLabel, self.commentButton];
}

@end
