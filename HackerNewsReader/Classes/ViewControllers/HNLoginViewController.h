//
//  HNLoginViewController.h
//  HackerNewsReader
//
//  Created by Stanislav Sidelnikov on 02/11/15.
//  Copyright © 2015 Ryan Nystrom. All rights reserved.
//

@import UIKit;

@class HNSessionManager;

NS_ASSUME_NONNULL_BEGIN

@interface HNLoginViewController : UITableViewController

@property (nonatomic, strong) HNSessionManager *sessionManager;

@end

NS_ASSUME_NONNULL_END
