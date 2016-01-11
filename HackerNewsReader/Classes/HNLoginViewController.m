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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

}

- (void)login {
//    self.errorMessageLabel.hidden = YES;
//    HNLogin *login = [[HNLogin alloc] init];
//    [self showBlockingWaitOverlay];
//    [login loginUser:self.usernameField.text
//        withPassword:self.passwordField.text
//          completion:^(NSString *username, NSError *error){
//              dispatch_async(dispatch_get_main_queue(), ^{
//                  [self removeAllOverlays];
//                  if (username) {
//                      if (self.loginDelegate && [self.loginDelegate respondsToSelector:@selector(loginSucceeded:)]) {
//                          [self.loginDelegate loginSucceeded:username];
//                      }
//                  } else {
//                      self.errorMessageLabel.text = NSLocalizedString(@"Unable to login. Check username and password and try again.", @"Unable to login message");
//                      self.errorMessageLabel.hidden = NO;
//                  }
//              });
//    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([tableView cellForRowAtIndexPath:indexPath] == self.loginCell) {
        [self login];
    }
}

#pragma mark - Keyboard interaction

- (void)keyboardWillShow:(NSNotification *)aNotification {}

- (void)keyboardWillHide:(NSNotification *)aNotification {}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.textFields makeObjectsPerformSelector:@selector(resignFirstResponder)];
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
