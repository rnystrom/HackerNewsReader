//
//  UIViewController+Sharing.m
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 6/1/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import "UIViewController+Sharing.h"

#import <TUSafariActivity/TUSafariActivity.h>

@implementation UIViewController (Sharing)

- (void)shareURL:(NSURL *)url fromBarItem:(UIBarButtonItem *)item {
    NSAssert(url != nil, @"Cannot share a nil URL");
    if (url) {
        TUSafariActivity *activity = [[TUSafariActivity alloc] init];
        UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[url] applicationActivities:@[activity]];
        if (item && [activityController respondsToSelector:@selector(popoverPresentationController)]) {
            activityController.popoverPresentationController.barButtonItem = item;
        }

        UIViewController *presentationController = self.splitViewController ?: self;
        [presentationController presentViewController:activityController animated:YES completion:nil];
    }
}

@end
