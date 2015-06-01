//
//  HNPostControllerHandling.h
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 6/1/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

@import UIKit;

@class HNPost;

extern UIViewController *viewControllerForPost(HNPost *post);

extern UIViewController *viewControllerForURL(NSURL *url);
