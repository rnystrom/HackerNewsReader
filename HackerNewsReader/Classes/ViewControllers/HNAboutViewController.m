//
//  HNAboutViewController.m
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 2/2/16.
//  Copyright © 2016 Ryan Nystrom. All rights reserved.
//

#import "HNAboutViewController.h"

#import "UIFont+HackerNews.h"
#import "UIColor+HackerNews.h"

@interface HNAboutViewController ()

@property (nonatomic, weak) IBOutlet UITextView *textView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *textViewHeightConstraint;

@end

@implementation HNAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.textView.linkTextAttributes = @{
                                         NSFontAttributeName: [UIFont hn_commentLinkFont],
                                         NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle),
                                         NSForegroundColorAttributeName: [UIColor hn_titleTextColor],
                                         };
    self.textView.font = [UIFont hn_commentFont];
    self.textView.textColor = [UIColor hn_titleTextColor];

    self.textView.text = self.aboutText;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    UITextView *textView = self.textView;
    const CGSize size = [textView sizeThatFits:CGSizeMake(textView.frame.size.width, CGFLOAT_MAX)];
    self.textViewHeightConstraint.constant = size.height;
    [textView layoutIfNeeded];
    textView.contentOffset = CGPointZero;
}

@end
