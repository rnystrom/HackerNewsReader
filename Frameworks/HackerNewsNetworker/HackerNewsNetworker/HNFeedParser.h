//
//  HNParser.h
//  HackerNewsNetworker
//
//  Created by Ryan Nystrom on 4/5/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

@import Foundation;

#import "HNParseProtocol.h"

@class TFHpple, TFHppleElement, HNPost;

@interface HNFeedParser : NSObject <HNParseProtocol>

- (NSArray *)titlesFromParser:(TFHpple *)parser;
- (NSArray *)detailsFromParser:(TFHpple *)parser;
- (HNPost *)postFromTitleNode:(TFHppleElement *)titleNode detailNode:(TFHppleElement *)detailNode rank:(NSUInteger)rank;

@end
