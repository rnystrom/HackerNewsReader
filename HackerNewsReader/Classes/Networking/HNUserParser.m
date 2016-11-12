//
//  HNUserParser.m
//  HackerNewsNetworker
//
//  Created by Ryan Nystrom on 1/31/16.
//  Copyright © 2016 Ryan Nystrom. All rights reserved.
//

#import "HNUserParser.h"

#import "HNUser.h"

#import "TFHpple.h"

@implementation HNUserParser

static NSString *HNUserValue(TFHpple *parser, NSString *query) {
    TFHppleElement *node = [parser searchWithXPathQuery:query].firstObject;
    NSString *content = [node content];
    return [content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (id <NSCoding>)parseDataFromResponse:(NSData *)data queries:(HNQueries *)queries {
    if (!data.length) {
        return nil;
    }

    TFHpple *parser = [TFHpple hppleWithHTMLData:data];

    NSString *username = HNUserValue(parser, queries.userName);
    NSString *created = HNUserValue(parser, queries.userCreated);

    NSString *karmaString = HNUserValue(parser, queries.userKarma);
    NSNumber *karma = @(karmaString.integerValue);

    NSString *about;
    TFHppleElement *aboutNode = [[parser searchWithXPathQuery:queries.userAbout] firstObject];
    TFHppleElement *form = [[aboutNode searchWithXPathQuery:@"//textarea[@name='about']"] firstObject];
    if (form != nil) {
        about = [form content];
    } else {
        about = [aboutNode content];
    }
    about = [about stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    return [[HNUser alloc] initWithUsername:username aboutText:about createdText:created karma:karma];
}

@end
