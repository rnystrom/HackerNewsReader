//
//  HNLoginViewController.m
//  HackerNewsReader
//
//  Created by Stanislav Sidelnikov on 02/11/15.
//  Copyright © 2015 Ryan Nystrom. All rights reserved.
//

#import "HNLoginViewController.h"

#import <HackerNewsNetworker/HNLogin.h>
#import <HackerNewsNetworker/HNSession.h>

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

- (void)showLoading:(BOOL)showLoading {
    UIBarButtonItem *item = nil;
    if (showLoading) {
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [activityIndicator startAnimating];
        item = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    }
    self.navigationItem.rightBarButtonItem = item;

    for (UITextField *textField in self.textFields) {
        textField.enabled = !showLoading;
    }

    UITableViewCell *loginCell = self.loginCell;
    loginCell.selectionStyle = UITableViewCellSelectionStyleNone;
    loginCell.userInteractionEnabled = !showLoading;
    loginCell.alpha = showLoading ? 0.5 : 1;
}

- (BOOL)formIsValid {
    for (UITextField *textField in self.textFields) {
        if (textField.text.length == 0) {
            return NO;
        }
    }
    return YES;
}

- (void)login {
    [self clearResponders];

    if (![self formIsValid]) {
        return;
    }

    [self showLoading:YES];

    [HNLogin loginUser:self.usernameTextField.text
        withPassword:self.passwordTextField.text
          completion:^(HNSession *session, NSError *error) {
              [self showLoading:NO];

              if (session) {
                  [self loginSucceededWithSession:session];
              } else {
                  [self showErrorMessage];
              }
          }];
}

- (void)loginSucceededWithSession:(HNSession *)session {
    [self performSegueWithIdentifier:@"LoginSuccess" sender:self];
}

- (void)showErrorMessage {
    NSString *title = NSLocalizedString(@"Error", nil);
    NSString *message = NSLocalizedString(@"Cannot sign in at this time with credentials provided.", nil);
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];

    NSString *okTitle = NSLocalizedString(@"Ok", nil);
    [controller addAction:[UIAlertAction actionWithTitle:okTitle style:UIAlertActionStyleDefault handler:nil]];

    [self presentViewController:controller animated:YES completion:nil];
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
