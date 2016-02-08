//
//  UIViewController+Storyboards.m
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 2/4/16.
//  Copyright © 2016 Ryan Nystrom. All rights reserved.
//

#import "UIViewController+Storyboards.h"

@implementation UIViewController (Storyboards)

+ (NSString *)hn_storyboardIdentifier {
    return NSStringFromClass(self.class);
}

@end
