//
//  HNComment+Links.m
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 5/12/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import "HNComment+Links.h"

@implementation HNComment (Links)

- (NSURL *)permalink {
    NSString *urlString = [NSString stringWithFormat:@"https://news.ycombinator.com/item?id=%zi", self.pk];
    NSURL *url = [NSURL URLWithString:urlString];
    return url;
}

@end
