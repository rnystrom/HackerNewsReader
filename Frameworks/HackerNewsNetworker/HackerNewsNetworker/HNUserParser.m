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

static NSString *HNUserValue(TFHpple *parser, NSString *query) {
    NSString *value = [parser searchWithXPathQuery:query].firstObject;
    return [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (id <NSCoding>)parseDataFromResponse:(NSData *)data queries:(HNQueries *)queries {
    if (!data.length) {
        return nil;
    }

    TFHpple *parser = [TFHpple hppleWithHTMLData:data];

    NSString *username = HNUserValue(parser, queries.userName);
    NSString *created = HNUserValue(parser, queries.userCreated);
    NSString *about = HNUserValue(parser, queries.userAbout);

    NSString *karmaString = HNUserValue(parser, queries.userKarma);
    NSNumber *karma = @(karmaString.integerValue);

    return [[HNUser alloc] initWithUsername:username aboutText:about createdText:created karma:karma];
}

@end
