//
//  HNTextItem.m
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 4/26/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import "HNTextRenderer.h"

#import <os/lock.h>

#define HNTextRendererHeightNotCalculated CGFLOAT_MAX

@interface HNTextRenderer () {
    os_unfair_lock _heightLock;
    os_unfair_lock _contentsLock;
}

@property (nonatomic, strong, readonly) NSLayoutManager *layoutManager;
@property (nonatomic, strong, readonly) NSTextContainer *textContainer;
@property (nonatomic, strong, readonly) NSTextStorage *textStorage;

@end

@implementation HNTextRenderer

@synthesize contents = _contents;
@synthesize height = _height;

- (instancetype)initWithAttributedString:(NSAttributedString *)attributedString width:(CGFloat)width {
    if (self = [super init]) {
        _height = HNTextRendererHeightNotCalculated;
        _width = width;
        _heightLock = OS_UNFAIR_LOCK_INIT;
        _contentsLock = OS_UNFAIR_LOCK_INIT;

        _attributedString = attributedString;

        _textContainer = [[NSTextContainer alloc] initWithSize:CGSizeMake(_width, CGFLOAT_MAX)];
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
    os_unfair_lock_lock(&_heightLock);
    if (_height == HNTextRendererHeightNotCalculated) {
        NSRange glyphRange = [self.layoutManager glyphRangeForTextContainer:self.textContainer];
        CGRect bounds = [self.layoutManager boundingRectForGlyphRange:glyphRange inTextContainer:self.textContainer];
        _height = bounds.size.height;
    }
    os_unfair_lock_unlock(&_heightLock);
    return _height;
}

- (id)contents {
    os_unfair_lock_lock(&_contentsLock);
    if (!_contents) {
        // accessing height here will calculate it if not done so
        CGSize size = CGSizeMake(self.textContainer.size.width, self.height);
        UIGraphicsBeginImageContextWithOptions(size, YES, [UIScreen mainScreen].scale);
        [[UIColor whiteColor] setFill];
        size.height += 1.0;
        [[UIBezierPath bezierPathWithRect:(CGRect){CGPointZero, size}] fill];
        NSRange glyphRange = [self.layoutManager glyphRangeForTextContainer:self.textContainer];
        [self.layoutManager drawBackgroundForGlyphRange:glyphRange atPoint:CGPointZero];
        [self.layoutManager drawGlyphsForGlyphRange:glyphRange atPoint:CGPointZero];
        _contents = (id)UIGraphicsGetImageFromCurrentImageContext().CGImage;
        UIGraphicsEndImageContext();
    }
    os_unfair_lock_unlock(&_contentsLock);
    return _contents;
}


#pragma mark - Public API

- (NSDictionary *)attributesAtPoint:(CGPoint)point {
    CGFloat fractionDistance;
    NSUInteger index = [self.layoutManager characterIndexForPoint:point inTextContainer:self.textContainer fractionOfDistanceBetweenInsertionPoints:&fractionDistance];
    if (index != NSNotFound && fractionDistance < 1.0) {
        return [self.attributedString attributesAtIndex:index effectiveRange:nil];
    }
    return nil;
}

- (void)invalidate {
    os_unfair_lock_lock(&_heightLock);
    _height = HNTextRendererHeightNotCalculated;
    os_unfair_lock_unlock(&_heightLock);

    os_unfair_lock_lock(&_contentsLock);
    CGImageRelease((CGImageRef)_contents);
    _contents = nil;
    os_unfair_lock_unlock(&_contentsLock);
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
