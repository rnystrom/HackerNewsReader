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

- (HNTextRenderer *)rendererForAttributedString:(NSAttributedString *)attributedString size:(CGSize)size {
    OSSpinLockLock(&_propertyLock);
    HNTextRenderer *renderer = self.cachedTextItems[attributedString];
    if (!renderer) {
        renderer = [[HNTextRenderer alloc] initWithAttributedString:attributedString size:size];
        self.cachedTextItems[attributedString] = renderer;
    }
    OSSpinLockUnlock(&_propertyLock);
    return renderer;
}

- (CGFloat)heightForAttributedString:(NSAttributedString *)attributedString size:(CGSize)size {
    HNTextRenderer *item = [self rendererForAttributedString:attributedString size:size];
    return item.height;
}

- (id)renderedContentForAttributedString:(NSAttributedString *)attributedString size:(CGSize)size {
    HNTextRenderer *item = [self rendererForAttributedString:attributedString size:size];
    return item.contents;
}

@end
