//
//  HNLoginViewController.h
//  HackerNewsReader
//
//  Created by Stanislav Sidelnikov on 02/11/15.
//  Copyright © 2015 Ryan Nystrom. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HNLoginDelegate <NSObject>

- (void)loginSucceeded:(NSString *)username;

@end

@interface HNLoginViewController : UIViewController

@property (nonatomic, strong) id <HNLoginDelegate> loginDelegate;

@end