//
//  HNWebViewController.h
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 4/6/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HNPost;

@interface HNWebViewController : UIViewController

- (instancetype)initWithPost:(HNPost *)post;
- (instancetype)initWithURL:(NSURL *)url NS_DESIGNATED_INITIALIZER;

@end
