//
//  UIViewController+Sharing.h
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 6/1/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (Sharing)

- (void)hn_shareURL:(NSURL *)url fromBarItem:(UIBarButtonItem *)item;

@end

NS_ASSUME_NONNULL_END
