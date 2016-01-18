//
//  HNCommentParser.h
//  HackerNewsNetworker
//
//  Created by Ryan Nystrom on 4/11/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

@import Foundation;

#import "HNParseProtocol.h"

@class TFHpple;
@class TFHppleElement;

NS_ASSUME_NONNULL_BEGIN

@interface HNCommentParser : NSObject <HNParseProtocol>

- (NSArray *)commentsFromParser:(TFHpple *)parser queries:(HNQueries *)queries;

- (NSArray *)commentComponentsFromNode:(TFHppleElement *)node;

@end

NS_ASSUME_NONNULL_END
