//
//  NSString+HackerNewsNetworker.m
//  HackerNewsNetworker
//
//  Created by Ryan Nystrom on 1/16/16.
//  Copyright © 2016 Ryan Nystrom. All rights reserved.
//

#import "NSString+HackerNewsNetworker.h"

@implementation NSString (HackerNewsNetworker)

- (NSDictionary *)hn_queryParameters {
    NSCharacterSet *pathCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"?&"];
    NSCharacterSet *parameterCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"="];
    NSArray *components = [self componentsSeparatedByCharactersInSet:pathCharacterSet];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithCapacity:components.count];
    for (NSString *component in components) {
        NSArray *params = [component componentsSeparatedByCharactersInSet:parameterCharacterSet];
        if (params.count == 2) {
            parameters[params.firstObject] = params.lastObject;
        }
    }
    return parameters;
}

@end
