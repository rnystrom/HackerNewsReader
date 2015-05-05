//
//  HNTextStorage.m
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 4/26/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import "HNTextStorage.h"

#import <libkern/OSAtomic.h>

#import "HNTextRenderer.h"

@interface HNTextStorage () {
    OSSpinLock _propertyLock;
}

@property (atomic, copy) NSMutableDictionary *cachedTextItems;

@end

@implementation HNTextStorage

- (instancetype)init {
    if (self = [super init]) {
        _cachedTextItems = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (HNTextRenderer *)rendererForAttributedString:(NSAttributedString *)attributedString width:(CGFloat)width {
    OSSpinLockLock(&_propertyLock);
    id cacheKey = @(width);
    id rendererKey = attributedString;
    NSMutableDictionary *sizeCache = self.cachedTextItems[cacheKey];
    if (!sizeCache) {
        sizeCache = [[NSMutableDictionary alloc] init];
        self.cachedTextItems[cacheKey] = sizeCache;
    }
    HNTextRenderer *renderer = sizeCache[rendererKey];
    if (!renderer) {
        renderer = [[HNTextRenderer alloc] initWithAttributedString:attributedString width:width];
        sizeCache[rendererKey] = renderer;
    }
    OSSpinLockUnlock(&_propertyLock);
    return renderer;
}

- (CGFloat)heightForAttributedString:(NSAttributedString *)attributedString width:(CGFloat)width {
    HNTextRenderer *item = [self rendererForAttributedString:attributedString width:width];
    return item.height;
}

- (id)renderedContentForAttributedString:(NSAttributedString *)attributedString width:(CGFloat)width {
    HNTextRenderer *item = [self rendererForAttributedString:attributedString width:width];
    return item.contents;
}

- (NSDictionary *)attributesForAttributedString:(NSAttributedString *)attributedString width:(CGFloat)width point:(CGPoint)point {
    HNTextRenderer *item = [self rendererForAttributedString:attributedString width:width];
    return [item attributesAtPoint:point];
}

@end
