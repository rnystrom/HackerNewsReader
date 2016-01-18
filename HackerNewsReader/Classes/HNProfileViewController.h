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

@interface HNProfileViewController : UITableViewController

@property (nonatomic, strong) HNUser *user;
@property (nonatomic, assign) BOOL displayAsSessionUser;

@end
