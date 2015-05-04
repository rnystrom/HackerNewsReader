//
//  HNTextItem.m
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 4/26/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import "HNTextRenderer.h"

#import <libkern/OSAtomic.h>

#define HNTextRendererHeightNotCalculated CGFLOAT_MAX

@interface HNTextRenderer () {
    OSSpinLock _heightLock;
    OSSpinLock _contentsLock;
}

@property (nonatomic, strong, readonly) NSLayoutManager *layoutManager;
@property (nonatomic, strong, readonly) NSTextContainer *textContainer;
@property (nonatomic, strong, readonly) NSTextStorage *textStorage;

@end

@implementation HNTextRenderer

@synthesize contents = _contents;
@synthesize height = _height;

- (instancetype)initWithAttributedString:(NSAttributedString *)attributedString size:(CGSize)size {
    if (self = [super init]) {
        _height = HNTextRendererHeightNotCalculated;
        _heightLock = OS_SPINLOCK_INIT;
        _contentsLock = OS_SPINLOCK_INIT;

        _attributedString = attributedString;

        _textContainer = [[NSTextContainer alloc] initWithSize:size];
        _textContainer.lineFragmentPadding = 0.0;

        _layoutManager = [[NSLayoutManager alloc] init];
        [_layoutManager addTextContainer:_textContainer];

        _textStorage = [[NSTextStorage alloc] initWithAttributedString:attributedString];
        [_textStorage addLayoutManager:_layoutManager];
    }
    return self;
}


#pragma mark - Getters

- (CGFloat)height {
    OSSpinLockLock(&_heightLock);
    if (_height == HNTextRendererHeightNotCalculated) {
        NSRange glyphRange = [self.layoutManager glyphRangeForTextContainer:self.textContainer];
        CGRect bounds = [self.layoutManager boundingRectForGlyphRange:glyphRange inTextContainer:self.textContainer];
        _height = bounds.size.height;
    }
    OSSpinLockUnlock(&_heightLock);
    return _height;
}

- (id)contents {
    OSSpinLockLock(&_contentsLock);
    if (!_contents) {
        // accessing height here will calculate it if not done so
        CGSize size = CGSizeMake(self.textContainer.size.width, self.height);
        UIGraphicsBeginImageContextWithOptions(size, YES, [UIScreen mainScreen].scale);
        [[UIColor whiteColor] setFill];
        [[UIBezierPath bezierPathWithRect:(CGRect){CGPointZero, size}] fill];
        NSRange glyphRange = [self.layoutManager glyphRangeForTextContainer:self.textContainer];
        [self.layoutManager drawBackgroundForGlyphRange:glyphRange atPoint:CGPointZero];
        [self.layoutManager drawGlyphsForGlyphRange:glyphRange atPoint:CGPointZero];
        _contents = (id)UIGraphicsGetImageFromCurrentImageContext().CGImage;
        UIGraphicsEndImageContext();
    }
    OSSpinLockUnlock(&_contentsLock);
    return _contents;
}


#pragma mark - Actions

- (void)invalidate {
    OSSpinLockLock(&_heightLock);
    _height = HNTextRendererHeightNotCalculated;
    OSSpinLockUnlock(&_heightLock);

    OSSpinLockLock(&_contentsLock);
    CGImageRelease((CGImageRef)_contents);
    _contents = nil;
    OSSpinLockUnlock(&_contentsLock);
}


#pragma mark - Comparison

- (NSUInteger)hash {
    return [self.textStorage hash] ^ [self.textContainer hash] ^ [self.layoutManager hash];
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:HNTextRenderer.class]) {
        HNTextRenderer *comp = (HNTextRenderer *)object;
        return [comp.textStorage isEqual:self.textStorage] ^ [self.textContainer hash] ^ [self.layoutManager hash];
    }
    return NO;
}

@end
