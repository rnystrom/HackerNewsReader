//
//  HNProfileViewController.m
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 1/10/16.
//  Copyright © 2016 Ryan Nystrom. All rights reserved.
//

#import "HNProfileViewController.h"

#import <HackerNewsNetworker/HNDataCoordinator.h>
#import <HackerNewsNetworker/HNUserParser.h>

#import <HackerNewsKit/HNUser.h>

#import <HackerNewsNetworker/HNSession.h>
#import <HackerNewsNetworker/HNLogin.h>

#import "HNSessionManager.h"

static NSInteger kHNSignoutCellSection = 2;

@interface HNProfileViewController() <HNDataCoordinatorDelegate>

@property (nonatomic, weak) IBOutlet UITableViewCell *signoutCell;

@property (nonatomic, strong, readonly) HNDataCoordinator *dataCoordinator;

@end

@implementation HNProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSString *username = self.user.username;
    self.navigationItem.title = username;

    HNUserParser *parser = [[HNUserParser alloc] init];
    NSString *cacheName = [NSString stringWithFormat:@"%@.page",username];
    dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _dataCoordinator = [[HNDataCoordinator alloc] initWithDelegate:self delegateQueue:q path:@"user" parser:parser cacheName:cacheName];
    [_dataCoordinator fetchWithParams:@{ @"id": username }];
}


#pragma mark - Private API

- (void)logout {
    NSCAssert(self.displayAsSessionUser, @"Should not be logging out from other users");
    const BOOL canLogout = [HNLogin logoutCurrentUser:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showLoading:NO];
            [self.sessionManager transitionToLoggedOutAnimated:YES];
        });
    }];
    if (canLogout) {
        [self showLoading:YES];
    }
}

- (void)showLoading:(BOOL)showLoading {
    UIBarButtonItem *item = nil;
    if (showLoading) {
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [activityIndicator startAnimating];
        item = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    }
    self.navigationItem.rightBarButtonItem = item;

    UITableViewCell *loginCell = self.signoutCell;
    loginCell.selectionStyle = UITableViewCellSelectionStyleNone;
    loginCell.userInteractionEnabled = !showLoading;
    loginCell.alpha = showLoading ? 0.5 : 1;
}


#pragma mark - HNDataCoordinatorDelegate

- (void)dataCoordinator:(HNDataCoordinator *)dataCoordinator didUpdateObject:(id)object {
    NSLog(@"%@",object);
}

- (void)dataCoordinator:(HNDataCoordinator *)dataCoordinator didError:(NSError *)error {}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == kHNSignoutCellSection) {
        [self logout];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kHNSignoutCellSection && !self.displayAsSessionUser) {
        return 0.0;
    }
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

@end
