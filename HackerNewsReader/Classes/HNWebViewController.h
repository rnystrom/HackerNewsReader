//
//  HNWebViewController.h
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 4/6/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

@import UIKit;

@class HNPost;

NS_ASSUME_NONNULL_BEGIN

@interface HNWebViewController : UIViewController

- (instancetype)initWithPost:(HNPost *)post;

- (instancetype)initWithURL:(NSURL *)url NS_DESIGNATED_INITIALIZER;

- (id)init NS_UNAVAILABLE;
- (id)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (id)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
