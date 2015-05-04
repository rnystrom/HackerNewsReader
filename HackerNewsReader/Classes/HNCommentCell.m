//
//  HNCommentCell.m
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 4/11/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import "HNCommentCell.h"

#import "UIColor+HackerNews.h"
#import "UIFont+HackerNews.h"

#import "HNComment+AttributedStrings.h"

@interface HNCommentCell ()

@end

@implementation HNCommentCell

@synthesize commentContentView = _commentContentView;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.clipsToBounds = YES;

        _commentContentView = [[UIView alloc] init];
        _commentContentView.opaque = YES;
        _commentContentView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:_commentContentView];

        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
        tap.numberOfTapsRequired = 1;
        tap.numberOfTouchesRequired = 1;
        [tap addTarget:self action:@selector(onTapGesture:)];
        [self.contentView addGestureRecognizer:tap];

        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] init];
        longPress.numberOfTapsRequired = 1;
        longPress.numberOfTouchesRequired = 1;
        [longPress addTarget:self action:@selector(onLongPressGesture:)];
        [self.contentView addGestureRecognizer:longPress];
    }
    return self;
}


#pragma mark - Layout

+ (UIEdgeInsets)contentInsetsForIndentationLevel:(NSUInteger)indentationLevel indentationWidth:(CGFloat)indentationWidth {
    return UIEdgeInsetsMake(8.0, 15.0 + indentationLevel * indentationWidth, 8.0, 15.0);
}

- (UIEdgeInsets)contentInsets {
    return [self.class contentInsetsForIndentationLevel:self.indentationLevel indentationWidth:self.indentationWidth];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGRect frame = UIEdgeInsetsInsetRect(self.bounds, self.contentInsets);
    self.commentContentView.frame = frame;
}


#pragma mark - Gestures

- (void)onTapGesture:(UITapGestureRecognizer *)recognizer {
    CGPoint point = [recognizer locationInView:self.commentContentView];
    if ([self.delegate respondsToSelector:@selector(commentCell:didTapCommentAtPoint:)]) {
        [self.delegate commentCell:self didTapCommentAtPoint:point];
    }
}

- (void)onLongPressGesture:(UILongPressGestureRecognizer *)recognizer {
    CGPoint point = [recognizer locationInView:self.commentContentView];
    if ([self.delegate respondsToSelector:@selector(commentCell:didLongPressCommentAtPoint:)]) {
        [self.delegate commentCell:self didLongPressCommentAtPoint:point];
    }
}

@end
