//
//  HNProfileViewController.m
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 1/10/16.
//  Copyright © 2016 Ryan Nystrom. All rights reserved.
//

#import "HNProfileViewController.h"

#import <HackerNewsKit/HNUser.h>

#import <HackerNewsNetworker/HNSession.h>

@implementation HNProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.user.username;
}

@end
