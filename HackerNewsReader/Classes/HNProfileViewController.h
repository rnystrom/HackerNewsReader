//
//  HNProfileViewController.h
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 1/10/16.
//  Copyright © 2016 Ryan Nystrom. All rights reserved.
//

@import UIKit;

@class HNUser;
@class HNSession;
@class HNSessionManager;

@interface HNProfileViewController : UITableViewController

@property (nonatomic, strong) HNUser *user;
@property (nonatomic, assign) BOOL displayAsSessionUser;
@property (nonatomic, strong) HNSessionManager *sessionManager;

@end
