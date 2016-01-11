//
//  HNLoginViewController.m
//  HackerNewsReader
//
//  Created by Stanislav Sidelnikov on 02/11/15.
//  Copyright © 2015 Ryan Nystrom. All rights reserved.
//

#import "HNLoginViewController.h"

#import <HackerNewsNetworker/HNLogin.h>

#import "UIViewController+HNOverlay.h"

@interface HNLoginViewController () <UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UITextField *usernameTextField;
@property (nonatomic, strong) IBOutlet UITextField *passwordTextField;
@property (nonatomic, weak) IBOutlet UITableViewCell *loginCell;

@property (nonatomic, strong) NSArray *textFields;

@end

@implementation HNLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.textFields = @[self.usernameTextField, self.passwordTextField];
}


#pragma mark - Private API

- (void)clearResponders {
    [self.textFields makeObjectsPerformSelector:@selector(resignFirstResponder)];
}

- (void)showLoadingSpinner:(BOOL)doShowSpinner {
    UIBarButtonItem *item = nil;
    if (doShowSpinner) {
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [activityIndicator startAnimating];
        item = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    }
    self.navigationItem.rightBarButtonItem = item;
}

- (void)login {
    [self clearResponders];
    [self showLoadingSpinner:YES];

    HNLogin *login = [[HNLogin alloc] init];
    [login loginUser:self.usernameTextField.text
        withPassword:self.passwordTextField.text
          completion:^(NSString *username, NSError *error) {
              dispatch_async(dispatch_get_main_queue(), ^{
                  [self showLoadingSpinner:NO];
                  if (username) {
                      NSLog(@"username");
                  } else {
                      NSLog(@"%@",error.localizedDescription);
                  }
              });
          }];
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([tableView cellForRowAtIndexPath:indexPath] == self.loginCell) {
        [self login];
    }
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self clearResponders];
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    const NSInteger index = [self.textFields indexOfObject:textField];
    if (index < self.textFields.count - 1) {
        [self.textFields[index + 1] becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    return NO;
}

@end
