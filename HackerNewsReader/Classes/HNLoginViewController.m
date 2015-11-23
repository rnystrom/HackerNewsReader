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

@interface HNLoginViewController () <UIScrollViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) UIView *focusedView;
@property (nonatomic) NSInteger viewMovedUpBy;

@end

@implementation HNLoginViewController

- (void)viewDidLoad {
    // Account for status and navigation bars when using autolayout
    // See http://stackoverflow.com/a/18785646/758990
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
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

- (IBAction)loginPressed:(UIButton *)sender {
    HNLogin *login = [[HNLogin alloc] init];
    [self showBlockingWaitOverlay];
    [login loginUser:self.usernameField.text
        withPassword:self.passwordField.text
          completion:^(NSString *username, NSError *error){
              dispatch_async(dispatch_get_main_queue(), ^{
                  [self removeAllOverlays];
                  if (username) {
                      if (self.loginDelegate && [self.loginDelegate respondsToSelector:@selector(loginSucceeded:)]) {
                          [self.loginDelegate loginSucceeded:username];
                      }
                  } else {
                      // TODO Show error message
                  }
              });
    }];
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

- (IBAction)textFieldDidBeginEditing:(id)sender {
    if ([sender isKindOfClass:[UIView class]]) {
        UIView *view = (UIView *)sender;
        self.focusedView = view;
    }
}

- (IBAction)textFieldDidEndEditing:(id)sender {
    self.focusedView = nil;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.x != 0) {
        CGPoint offset = scrollView.contentOffset;
        offset.x = 0;
        scrollView.contentOffset = offset;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSInteger nextTag = textField.tag + 1;
    // Try to find next responder
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    if (nextResponder) {
        // Found next responder, so set it.
        [nextResponder becomeFirstResponder];
    } else {
        // Not found, so remove keyboard.
        [textField resignFirstResponder];
    }
    return NO; // We do not want UITextField to insert line-breaks.
}

# pragma mark - Keyboard interaction

- (void)keyboardWillShow:(NSNotification *)aNotification {

    
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, self.focusedView.frame.origin) ) {
        [self.scrollView scrollRectToVisible:self.focusedView.frame animated:YES];
    }
}

- (void)keyboardWillHide:(NSNotification *)aNotification {

    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

@end
