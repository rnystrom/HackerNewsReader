//
//  HNCommentParser.h
//  HackerNewsNetworker
//
//  Created by Ryan Nystrom on 4/11/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HNParseProtocol.h"

@class TFHpple, TFHppleElement;

@interface HNCommentParser : NSObject <HNParseProtocol>

- (NSArray *)commentsFromParser:(TFHpple *)parser;
- (NSArray *)commentComponentsFromNode:(TFHppleElement *)node;

@end
