//
//  UIViewController+HNComment.m
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 5/31/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import "UIViewController+HNComment.h"

#import <objc/runtime.h>

#import "HNComment.h"

#import "HNComment+Links.h"
#import "HNComment+AttributedStrings.h"
#import "HNProfileViewController.h"
#import "UIViewController+Storyboards.h"

#define COPY_TEXT_ACTION NSLocalizedString(@"Copy Text", @"Copy the text of the comment")
#define OPEN_SAFARI_ACTION NSLocalizedString(@"Open in Safari", @"Open the comment in Safari")
#define COPY_LINK_ACTION NSLocalizedString(@"Copy Permalink", @"Copy a link to the comment")
#define COMMENT_TITLE NSLocalizedString(@"Comment", @"String for for the title of someone's comment")
#define COMMENT_TITLE_FORMAT NSLocalizedString(@"%@'s comment", @"Formatted string for for the title of someone's comment")
#define CANCEL_ACTION NSLocalizedString(@"Cancel", @"Cancel")
#define VIEW_PROFILE_ACTION NSLocalizedString(@"View Profile", @"View the profile of the comment author")

@implementation UIViewController (HNComment)

- (void)showActionSheetForComment:(HNComment *)comment fromView:(UIView *)view {
    const BOOL hasUsername = comment.user.username.length > 0;
    NSString *title;
    if (hasUsername) {
        title = [NSString stringWithFormat:COMMENT_TITLE_FORMAT, comment.user.username];
    } else {
        title = COMMENT_TITLE;
    }

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *openSafari = [UIAlertAction actionWithTitle:OPEN_SAFARI_ACTION style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self openCommentPermalink:comment];
    }];
    UIAlertAction *copyText = [UIAlertAction actionWithTitle:COPY_TEXT_ACTION style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self copyCommentText:comment];
    }];
    UIAlertAction *copyLink = [UIAlertAction actionWithTitle:COPY_LINK_ACTION style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self copyCommentLink:comment];
    }];

    if (hasUsername) {
        UIAlertAction *viewProfile = [UIAlertAction actionWithTitle:VIEW_PROFILE_ACTION style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self viewProfile:comment];
        }];
        [alertController addAction:viewProfile];
    }

    UIAlertAction *cancel = [UIAlertAction actionWithTitle:CANCEL_ACTION style:UIAlertActionStyleCancel handler:nil];

    [alertController addAction:copyText];
    [alertController addAction:openSafari];
    [alertController addAction:copyLink];
    [alertController addAction:cancel];

    if ([alertController respondsToSelector:@selector(popoverPresentationController)]) {
        alertController.popoverPresentationController.sourceView = view;
        alertController.popoverPresentationController.sourceRect = view.bounds;
    }

    [self presentViewController:alertController animated:YES completion:nil];
}


#pragma mark - Private API

- (void)openCommentPermalink:(HNComment *)comment {
    NSURL *url = [comment permalink];
    UIApplication *app = [UIApplication sharedApplication];
    if ([app canOpenURL:url]) {
        [app openURL:url options:@{} completionHandler:nil];
    }
}

- (void)copyCommentText:(HNComment *)comment {
    NSString *text = [[comment attributedString] string];
    [[UIPasteboard generalPasteboard] setString:text];
}

- (void)copyCommentLink:(HNComment *)comment {
    [[UIPasteboard generalPasteboard] setString:[[comment permalink] absoluteString]];
}

- (void)viewProfile:(HNComment *)comment {
    NSString *identifier = [HNProfileViewController hn_storyboardIdentifier];
    HNProfileViewController *controller = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:identifier];
    controller.user = comment.user;
    [self.navigationController pushViewController:controller animated:YES];
}

@end
