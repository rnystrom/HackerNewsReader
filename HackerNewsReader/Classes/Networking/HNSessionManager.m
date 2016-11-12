//
//  HNSessionManager.m
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 1/16/16.
//  Copyright © 2016 Ryan Nystrom. All rights reserved.
//

#import "HNSessionManager.h"

#import "HNSession.h"

#import "HNProfileViewController.h"
#import "HNLoginViewController.h"
#import "UIViewController+Storyboards.h"

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
    NSString *identifier = [HNProfileViewController hn_storyboardIdentifier];
    HNProfileViewController *controller = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:identifier];
    controller.displayAsSessionUser = YES;
    controller.user = session.user;
    controller.sessionManager = self;
    [self.navigationController setViewControllers:@[ controller ] animated:animated];
}

- (void)transitionToLoggedOutAnimated:(BOOL)animated {
    NSString *identifier = [HNLoginViewController hn_storyboardIdentifier];
    HNLoginViewController *controller = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:identifier];
    controller.sessionManager = self;
    [self.navigationController setViewControllers:@[ controller ] animated:animated];
}

@end
