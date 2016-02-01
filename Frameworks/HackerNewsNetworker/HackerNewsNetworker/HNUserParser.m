//
//  HNUserParser.m
//  HackerNewsNetworker
//
//  Created by Ryan Nystrom on 1/31/16.
//  Copyright © 2016 Ryan Nystrom. All rights reserved.
//

#import "HNUserParser.h"

#import <HackerNewsKit/HNUser.h>

#import "TFHpple.h"

@implementation HNUserParser

- (id <NSCoding>)parseDataFromResponse:(NSData *)data queries:(HNQueries *)queries {
    if (!data.length) {
        return nil;
    }

    return nil;
}

@end
