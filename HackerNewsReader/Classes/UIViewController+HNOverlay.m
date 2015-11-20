//
//  UIViewController+HNOverlay.m
//  HackerNewsReader
//
//  Created by Stanislav Sidelnikov on 20/11/15.
//  Copyright © 2015 Ryan Nystrom. All rights reserved.
//

#import "UIViewController+HNOverlay.h"

@implementation UIViewController (HNOverlay)

- (UIView *)showWaitOverlay {
    return [HNOverlay showCenteredWaitOverlay:self.view];
}

- (UIView *)showWaitOverlayWithText:(NSString *)text {
    return [HNOverlay showCenteredWaitOverlay:self.view
                                     withText:text];
}

- (void)removeAllOverlays {
    [HNOverlay removeAllBlockingOverlays];
}

- (void)removeOverlayText:(NSString *)text {
    [HNOverlay updateOverlayText:self.view withText:text];
}

@end

@implementation HNOverlay

// Some arbitrary number
#define CONTAINER_VIEW_TAG 456987123
#define CORNER_RADIUS 10.0
#define PADDING 10.0

#pragma mark - Public class methods: blocking

+ (UIView *)showBlockingWaitOverlay {
    UIView *blocker = [self addMainWindowBlocker];
    [self showCenteredWaitOverlay:blocker];
    
    return blocker;
}

+ (UIView *)showBlockingWaitOverlayWithText:(NSString *)text {
    UIView *blocker = [self addMainWindowBlocker];
    [self showCenteredWaitOverlay:blocker withText:text];
    
    return blocker;
}

+ (void)removeAllBlockingOverlays {
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    NSAssert(window, @"Unable to get shared application delegate's window.");

    [self removeAllOverlaysFromView:window];
}

#pragma mark - Public class methods: non-blocking

+ (UIView *)showCenteredWaitOverlay:(UIView *)parentView {
    UIActivityIndicatorView *ai = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [ai startAnimating];
    
    CGRect containerViewRect = CGRectMake(0, 0, ai.frame.size.width * 2, ai.frame.size.height * 2);
    
    UIView *containerView = [[UIView alloc] initWithFrame:containerViewRect];
    
    containerView.tag = CONTAINER_VIEW_TAG;
    containerView.layer.cornerRadius = CORNER_RADIUS;
    containerView.backgroundColor = [self backgroundColor];
    containerView.center = CGPointMake(parentView.bounds.size.width/2, parentView.bounds.size.height/2);
    
    ai.center = CGPointMake(containerView.bounds.size.width/2, containerView.bounds.size.height/2);
    
    [containerView addSubview:ai];
    [parentView addSubview:containerView];
    [self centerViewInSuperview:containerView];
    
    return containerView;
}

+ (UIView *)showCenteredWaitOverlay:(UIView *)parentView withText:(NSString *)text {
    UIActivityIndicatorView *ai = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [ai startAnimating];
    
    return [self showGenericOverlay:parentView withText:text accessoryView:ai];
}

+ (UIView *)showGenericOverlay:(UIView *)parentView withText:(NSString *)text accessoryView:(UIView *)accessoryView {
    UILabel *label = [self labelForText:text];
    CGFloat xOffset = PADDING;
    if (accessoryView) {
        xOffset += accessoryView.frame.size.width + PADDING;
    }
    label.frame = CGRectOffset(label.frame, xOffset, PADDING);

    CGFloat additionalWidth = 0;
    CGFloat actualHeight = label.frame.size.height;
    if (accessoryView) {
        additionalWidth += accessoryView.frame.size.width + PADDING;
        if (accessoryView.frame.size.height > actualHeight) {
            actualHeight = accessoryView.frame.size.height;
        }
    }
    CGSize actualSize = CGSizeMake(label.frame.size.width + PADDING * 2 + additionalWidth, actualHeight + PADDING * 2);
    
    CGRect containerViewRect = CGRectMake(0, 0, actualSize.width, actualSize.height);
    
    UIView *containerView = [[UIView alloc] initWithFrame:containerViewRect];
    
    containerView.tag = CONTAINER_VIEW_TAG;
    containerView.layer.cornerRadius = CORNER_RADIUS;
    containerView.backgroundColor = [self backgroundColor];
    containerView.center = CGPointMake(parentView.bounds.size.width/2, parentView.bounds.size.height/2);
    
    if (accessoryView) {
        accessoryView.frame = CGRectOffset(accessoryView.frame, PADDING, (actualSize.height - accessoryView.frame.size.height) / 2);
        [containerView addSubview:accessoryView];
    }
    [containerView addSubview:label];
    
    [parentView addSubview:containerView];
    [self centerViewInSuperview:containerView];
    
    return containerView;
}

+ (UIView *)showOverlay:(UIView *)parentView withText:(NSString *)text {
    return [self showGenericOverlay:parentView withText:text accessoryView:nil];
}

#define MAX_OVERLAYS 1000
+ (void)removeAllOverlaysFromView:(UIView *)parentView {
    UIView *overlay;
    
    NSInteger safeCounter = MAX_OVERLAYS;
    while (safeCounter-- > 0) {
        overlay = [parentView viewWithTag:CONTAINER_VIEW_TAG];
        if (overlay == nil) {
            break;
        }
        
        [overlay removeFromSuperview];
    }
    
    if (safeCounter <= 0) {
        NSLog(@"removeAllOverlaysFromView's loop reached %d counts and was interrupted. Might be some infinite loop problem.", MAX_OVERLAYS);
    }
}

+ (void)updateOverlayText:(UIView *)parentView withText:(NSString *)text {
    UIView *overlay = [parentView viewWithTag:CONTAINER_VIEW_TAG];
    if (overlay) {
        for (UIView *subview in overlay.subviews) {
            if ([subview isKindOfClass:[UILabel class]]) {
                UILabel *label = (UILabel*)subview;
                label.text = text;
                break;
            }
        }
    }
}

#pragma mark - Private class methods: properties

+ (UIColor *)backgroundColor {
    return [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
}

+ (UIColor *)textColor {
    return [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
}

+ (UIFont *)font {
    return [UIFont systemFontOfSize:14];
}

#pragma mark - Private class methods

+ (UILabel *)labelForText:(NSString *)text {
    CGSize textSize = [text sizeWithAttributes:@{NSFontAttributeName: [self font]}];
    
    CGRect labelRect = CGRectMake(0, 0, textSize.width, textSize.height);
    
    UILabel *label = [[UILabel alloc] initWithFrame:labelRect];
    label.font = [self font];
    label.textColor = [self textColor];
    label.text = text;
    label.numberOfLines = 0;
    
    return label;
}

+ (void)centerViewInSuperview:(UIView *)view {
    NSAssert(view.superview != nil, @"'view' should have a superview");
    
    view.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *constraintH = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:view.superview attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    NSLayoutConstraint *constraintV = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:view.superview attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    NSLayoutConstraint *constraintWidth = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:view.frame.size.width];
    NSLayoutConstraint *constraintHeight = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:view.frame.size.height];
    
    [view.superview addConstraints:@[constraintH, constraintV, constraintWidth, constraintHeight]];
}


+ (UIView *)addMainWindowBlocker {
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    NSAssert(window, @"Unable to get shared application delegate's window.");
    
    UIView *blocker = [[UIView alloc] initWithFrame:window.bounds];
    blocker.backgroundColor = [self backgroundColor];
    blocker.tag = CONTAINER_VIEW_TAG;
    
    blocker.translatesAutoresizingMaskIntoConstraints = NO;
    
    [window addSubview:blocker];
    
    NSDictionary *viewDictionary = @{@"blocker": blocker};
    
    NSArray *constraintsV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[blocker]-0-|" options:NSLayoutFormatAlignAllLeft metrics:nil views:viewDictionary];
    
    NSArray *constraintsH = [NSLayoutConstraint constraintsWithVisualFormat:@"|-0-[blocker]-0-|" options:NSLayoutFormatAlignAllLeft metrics:nil views:viewDictionary];
    
    [window addConstraints:[constraintsV arrayByAddingObjectsFromArray:constraintsH]];
    
    return blocker;
}

@end