//
//  HNParser.h
//  HackerNewsNetworker
//
//  Created by Ryan Nystrom on 4/5/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

@import Foundation;

#import "HNParseProtocol.h"

@class TFHpple;
@class TFHppleElement;
@class HNPost;

NS_ASSUME_NONNULL_BEGIN

@interface HNFeedParser : NSObject <HNParseProtocol>

- (HNPost *)postFromTitleNode:(TFHppleElement *)titleNode
                   detailNode:(TFHppleElement *)detailNode
                         rank:(NSUInteger)rank
                      queries:(HNQueries *)queries;

@end

NS_ASSUME_NONNULL_END
