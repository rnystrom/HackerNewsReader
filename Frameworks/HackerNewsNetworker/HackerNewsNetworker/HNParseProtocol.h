//
//  HNParseProtocol.h
//  HackerNewsNetworker
//
//  Created by Ryan Nystrom on 4/11/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HNParseProtocol <NSObject>

- (id <NSCopying, NSCoding>)parseDataFromResponse:(NSData *)data;

@end
