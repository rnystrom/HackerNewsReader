//
//  UIViewController+HNComment.m
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 5/31/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import "UIViewController+HNComment.h"

#import <objc/runtime.h>

#import <HackerNewsKit/HNComment.h>

#import "HNComment+Links.h"
#import "HNComment+AttributedStrings.h"

#define SUPPORTS_ALERTCONTROLLER (NSClassFromString(@"UIAlertController") != nil)
#define COPY_TEXT_ACTION NSLocalizedString(@"Copy Text", @"Copy the text of the comment")
#define OPEN_SAFARI_ACTION NSLocalizedString(@"Open in Safari", @"Open the comment in Safari")
#define COPY_LINK_ACTION NSLocalizedString(@"Copy Permalink", @"Copy a link to the comment")
#define COMMENT_TITLE_FORMAT NSLocalizedString(@"%@'s comment", @"Formatted string for for the title of someone's comment")
#define CANCEL_ACTION NSLocalizedString(@"Cancel", @"Cancel")

@implementation UIViewController (HNComment)

- (void)showActionSheetForComment:(HNComment *)comment fromView:(UIView *)view {
    NSString *title = [NSString stringWithFormat:COMMENT_TITLE_FORMAT, comment.user.username];

    if (SUPPORTS_ALERTCONTROLLER) {
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
    } else {
        [self setActionSheetComment:comment];
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:CANCEL_ACTION destructiveButtonTitle:nil otherButtonTitles:COPY_TEXT_ACTION, OPEN_SAFARI_ACTION, COPY_LINK_ACTION, nil];
        [actionSheet showInView:self.view];
    }
}


#pragma mark - Private API

- (void)setActionSheetComment:(HNComment *)actionSheetComment {
    objc_setAssociatedObject(self, @selector(actionSheetComment), actionSheetComment, OBJC_ASSOCIATION_RETAIN);
}

- (HNComment *)actionSheetComment {
    return objc_getAssociatedObject(self, @selector(actionSheetComment));
}

- (void)openCommentPermalink:(HNComment *)comment {
    NSURL *url = [comment permalink];
    UIApplication *app = [UIApplication sharedApplication];
    if ([app canOpenURL:url]) {
        [app openURL:url];
    }
}

- (void)copyCommentText:(HNComment *)comment {
    NSString *text = [[comment attributedString] string];
    [[UIPasteboard generalPasteboard] setString:text];
}

- (void)copyCommentLink:(HNComment *)comment {
    [[UIPasteboard generalPasteboard] setString:[[comment permalink] absoluteString]];
}


#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:OPEN_SAFARI_ACTION]) {
        [self openCommentPermalink:[self actionSheetComment]];
    } else if ([title isEqualToString:COPY_TEXT_ACTION]) {
        [self copyCommentText:[self actionSheetComment]];
    } else if ([title isEqualToString:COPY_LINK_ACTION]) {
        [self copyCommentLink:[self actionSheetComment]];
    }
    [self setActionSheetComment:nil];
}

@end
