//
//  UIViewController+ActivityIndicator.m
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 6/1/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import "UIViewController+ActivityIndicator.h"

#import <objc/runtime.h>

@implementation UIViewController (ActivityIndicator)

- (UIActivityIndicatorView *)hn_activityIndicator {
    SEL key = @selector(hn_activityIndicator);
    UIActivityIndicatorView *activityIndicator = objc_getAssociatedObject(self, key);
    if (!activityIndicator) {
        activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        objc_setAssociatedObject(self, key, activityIndicator, OBJC_ASSOCIATION_RETAIN);
    }
    return activityIndicator;
}

- (void)insertActivityIndicator {
    CGRect bounds = self.view.bounds;
    UIActivityIndicatorView *activityIndicator = self.hn_activityIndicator;
    activityIndicator.center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds) - self.navigationController.topLayoutGuide.length);
    activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    [activityIndicator startAnimating];
    [self.view addSubview:activityIndicator];
}

- (void)hideActivityIndicator {
    UIActivityIndicatorView *activityIndicator = self.hn_activityIndicator;
    [activityIndicator stopAnimating];
    [activityIndicator removeFromSuperview];
}

@end
