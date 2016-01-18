//
//  HNSessionManager.m
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 1/16/16.
//  Copyright © 2016 Ryan Nystrom. All rights reserved.
//

#import "HNSessionManager.h"

#import <HackerNewsNetworker/HNSession.h>

#import "HNProfileViewController.h"
#import "HNLoginViewController.h"

@interface HNSessionManager()

@property (nonatomic, weak, readonly) UINavigationController *navigationController;

@end

@implementation HNSessionManager

- (instancetype)initWithNavigationController:(UINavigationController *)navigationController {
    if (self = [super init]) {
        _navigationController = navigationController;
    }
    return self;
}

- (void)transitionToLoggedInWithSession:(HNSession *)session animated:(BOOL)animated {
    HNProfileViewController *controller = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"HNProfileViewController"];
    [self.navigationController setViewControllers:@[ controller ] animated:animated];
}

- (void)transitionToLoggedOutAnimated:(BOOL)animated {
    HNLoginViewController *controller = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"HNLoginViewController"];
    controller.sessionManager = self;
    [self.navigationController setViewControllers:@[ controller ] animated:animated];
}

@end
