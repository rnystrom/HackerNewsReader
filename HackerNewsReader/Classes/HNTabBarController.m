//
//  HNTabBarController.m
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 1/6/16.
//  Copyright © 2016 Ryan Nystrom. All rights reserved.
//

#import "HNTabBarController.h"

@implementation HNTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    for (UIViewController *controller in self.viewControllers) {
        controller.tabBarItem.imageInsets = UIEdgeInsetsMake(5.5, 0, -5.5, 0);
    }
}

@end
