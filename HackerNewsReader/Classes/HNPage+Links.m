//
//  HNPage+Links.m
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 5/13/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import "HNPage+Links.h"

@implementation HNPage (Links)

- (NSURL *)permalink {
    NSString *urlString = [NSString stringWithFormat:@"https://news.ycombinator.com/item?id=%zi", self.post.pk];
    NSURL *url = [NSURL URLWithString:urlString];
    return url;
}

@end
