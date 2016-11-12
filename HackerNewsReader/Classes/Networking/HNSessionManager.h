//
//  HNSessionManager.h
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 1/16/16.
//  Copyright © 2016 Ryan Nystrom. All rights reserved.
//

@import UIKit;

@class HNSession;

NS_ASSUME_NONNULL_BEGIN

@interface HNSessionManager : NSObject

- (instancetype)initWithNavigationController:(UINavigationController *)navigationController NS_DESIGNATED_INITIALIZER;

- (void)transitionToLoggedInWithSession:(HNSession *)session animated:(BOOL)animated;

- (void)transitionToLoggedOutAnimated:(BOOL)animated;

- (id)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
