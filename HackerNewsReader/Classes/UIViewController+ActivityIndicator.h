//
//  UIViewController+ActivityIndicator.h
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 6/1/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (ActivityIndicator)

- (UIActivityIndicatorView *)hn_activityIndicator;
- (void)insertActivityIndicator;
- (void)hideActivityIndicator;

@end
