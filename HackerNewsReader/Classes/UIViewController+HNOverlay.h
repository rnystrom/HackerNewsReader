//
//  UIViewController+HNOverlay.h
//  HackerNewsReader
//
//  Inspired by SwiftOverlays @ http://git.io/v45y6
//  Created by Stanislav Sidelnikov on 20/11/15.
//  Copyright © 2015 Ryan Nystrom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (HNOverlay)

/**
 Shows wait overlay with activity indicator, centered in the view controller's main view
 
 Do not use this method for **UITableViewController** or **UICollectionViewController**
 
 - returns: Created overlay
 */
- (UIView *)showWaitOverlay;

/**
 Shows blocking wait overlay with activity indicator, centered in the view controller's main view
 
 Do not use this method for **UITableViewController** or **UICollectionViewController**
 
 - returns: Created overlay
 */
- (UIView *)showBlockingWaitOverlay;

/**
 Shows wait overlay with activity indicator *and text*, centered in the view controller's main view
 
 Do not use this method for **UITableViewController** or **UICollectionViewController**
 
 - parameter text: Text to be shown on overlay
 
 - returns: Created overlay
 */
- (UIView *)showWaitOverlayWithText:(NSString *)text;

/**
 Shows blocking wait overlay with activity indicator *and text*, centered in the view controller's main view
 
 Do not use this method for **UITableViewController** or **UICollectionViewController**
 
 - parameter text: Text to be shown on overlay
 
 - returns: Created overlay
 */
- (UIView *)showBlockingWaitOverlayWithText:(NSString *)text;

/**
 Removes all overlays from view controller's main view
 */
- (void)removeAllOverlays;

/**
 Updates text on the current overlay.
 Does nothing if no overlay is present.
 
 - parameter text: Text to set
 */
- (void)removeOverlayText:(NSString *)text;

@end

@interface HNOverlay : NSObject



#pragma mark - Blocking overlays
/**
 Shows *blocking* wait overlay with activity indicator, centered in the app's main window
 
 - returns: Created overlay
 */
+ (UIView *)showBlockingWaitOverlay;

/**
 Shows *blocking* wait overlay with activity indicator, centered in the passed view
 
 - parameter blockedView: View to be blocked
 
 - returns: Created overlay
 */
+ (UIView *)showBlockingWaitOverlayForView:(UIView *)blockedView;

/**
 Shows wait overlay with activity indicator *and text*, centered in the app's main window
 
 - parameter text: Text to be shown on overlay
 
 - returns: Created overlay
 */
+ (UIView *)showBlockingWaitOverlayWithText:(NSString *)text;

/**
 Shows wait overlay with activity indicator *and text*, centered in the passed view
 
 - parameter text: Text to be shown on overlay
 - parameter blockedView: View to be blocked
 
 - returns: Created overlay
 */
+ (UIView *)showBlockingWaitOverlayForView:(UIView *)blockedView
                                  withText:(NSString *)text;

/**
 Removes all *blocking* overlays from application's *main window*
 */
+ (void)removeAllBlockingOverlays;

#pragma mark - Non-blocking overlays

+ (UIView *)showCenteredWaitOverlay:(UIView *)parentView;
+ (UIView *)showCenteredWaitOverlay:(UIView *)parentView withText:(NSString *)text;
+ (UIView *)showGenericOverlay:(UIView *)parentView
                      withText:(NSString *)text
                 accessoryView:(UIView *)accessoryView;
+ (UIView *)showOverlay:(UIView *)parentView withText:(NSString *)text;
+ (void)removeAllOverlaysFromView:(UIView *)parentView;
+ (void)updateOverlayText:(UIView *)parentView withText:(NSString *)text;


@end