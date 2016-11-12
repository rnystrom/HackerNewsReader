//
//  HNWebViewController.m
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 4/6/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import "HNWebViewController.h"

#import "HNPost.h"

#import <WebKit/WebKit.h>

#import "HNCommentViewController.h"
#import "UIColor+HackerNews.h"
#import "UIFont+HackerNews.h"
#import "TUSafariActivity.h"
#import "UIViewController+UISplitViewController.h"
#import "UIViewController+ActivityIndicator.h"
#import "UIViewController+Sharing.h"
#import "UINavigationController+HNBarState.h"
#import "AppDelegate.h"

#define SUPPORTS_WKWEBVIEW (NSClassFromString(@"WKWebView") != nil)

@interface HNWebViewController () <WKNavigationDelegate, UIWebViewDelegate>

@property (nonatomic, strong) UIView *webView;
@property (nonatomic, strong, readonly) HNPost *post;
@property (nonatomic, strong) UIView *statusBarBackgroundView;
@property (nonatomic, strong) UIBarButtonItem *backButton;
@property (nonatomic, strong) UIBarButtonItem *forwardButton;
@property (nonatomic, strong) UILabel *errorLabel;
@property (nonatomic, strong) UIBarButtonItem *shareBarButtonItem;

@end

@implementation HNWebViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithPost:(HNPost *)post {
    if (self = [self initWithURL:post.URL]) {
        _post = post;
    }
    return self;
}

- (instancetype)initWithURL:(NSURL *)url {
    if (self = [super initWithNibName:nil bundle:nil]) {
        if (SUPPORTS_WKWEBVIEW) {
            WKWebView *webView = [[WKWebView alloc] init];
            webView.navigationDelegate = self;
            webView.backgroundColor = [UIColor whiteColor];
            [webView loadRequest:[NSURLRequest requestWithURL:url]];
            _webView = webView;
        } else {
            UIWebView *webView = [[UIWebView alloc] init];
            webView.scalesPageToFit = YES;
            webView.delegate = self;
            webView.backgroundColor = [UIColor whiteColor];
            [webView loadRequest:[NSURLRequest requestWithURL:url]];
            _webView = webView;
        }
        self.title = url.absoluteString;

        self.hidesBottomBarWhenPushed = YES;

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTappedStatusBar:) name:kHNAppDelegateDidTapStatusBar object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];

    [self hn_configureLeftButtonAsDisplay];

    self.view.backgroundColor = [UIColor whiteColor];

    CGRect bounds = self.view.bounds;

    self.webView.frame = bounds;
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.webView];

    [self hn_insertActivityIndicator];

    self.statusBarBackgroundView = [[UIView alloc] initWithFrame:[UIApplication sharedApplication].statusBarFrame];
    self.statusBarBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.statusBarBackgroundView.backgroundColor = [self.navigationController.navigationBar.barTintColor colorWithAlphaComponent:0.95];
    [self.view addSubview:self.statusBarBackgroundView];

    self.errorLabel = [[UILabel alloc] init];
    self.errorLabel.hidden = YES;
    self.errorLabel.text = NSLocalizedString(@"Error loading page", @"There was an error loading the page");
    self.errorLabel.font = [UIFont hn_titleFont];
    self.errorLabel.textColor = [UIColor hn_subtitleTextColor];
    [self.errorLabel sizeToFit];
    self.errorLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.errorLabel.center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));;
    [self.view addSubview:self.errorLabel];

    self.backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backward"] style:UIBarButtonItemStylePlain target:self action:@selector(onBack:)];
    self.backButton.enabled = NO;
    self.backButton.accessibilityLabel = NSLocalizedString(@"Go back", @"Title for the web back button");
    self.forwardButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"forward"] style:UIBarButtonItemStylePlain target:self action:@selector(onForward:)];
    self.forwardButton.enabled = NO;
    self.forwardButton.accessibilityLabel = NSLocalizedString(@"Go forward", @"Title for the web forward button");
    UIBarButtonItem *refresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(onRefresh:)];
    refresh.accessibilityLabel = NSLocalizedString(@"Refresh Page", @"Title for the web refresh button");
    UIBarButtonItem *share = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(onShare:)];
    share.accessibilityLabel = NSLocalizedString(@"Share Page", @"Title for the web share button");
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

    if (self.post) {
        UIBarButtonItem *comments = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"chat"] style:UIBarButtonItemStylePlain target:self action:@selector(onComments:)];
        comments.accessibilityLabel = NSLocalizedString(@"View comments", @"Title for the comments button");
        self.toolbarItems = @[self.backButton, flex, self.forwardButton, flex, refresh, flex, share, flex, comments];
    } else {
        self.toolbarItems = @[self.backButton, flex, self.forwardButton, flex, refresh, flex, share];
    }

    self.shareBarButtonItem = share;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController hn_setHidesBarsOnSwipe:YES navigationBarHidden:NO toolbarHidden:NO animated:animated];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    CGFloat top = 0.0;
    if (size.width > size.height) {
        top = -[UIApplication sharedApplication].statusBarFrame.size.height;
    }
    CGRect frame = self.statusBarBackgroundView.frame;
    frame.origin.y = top;
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        self.statusBarBackgroundView.frame = frame;
    } completion:nil];
}


#pragma mark - Actions

- (void)onShare:(id)sender {
    NSURL *url;
    if (SUPPORTS_WKWEBVIEW) {
        url = [(WKWebView *)self.webView URL];
    } else {
        url = [[(UIWebView *)self.webView request] URL];
    }
    url = url ?: self.post.URL;
    [self hn_shareURL:url fromBarItem:self.shareBarButtonItem];
}

- (void)onComments:(id)sender {
    NSAssert(self.post != nil, @"Should not be pushing a comment controller for a nil post");
    HNCommentViewController *commentController = [[HNCommentViewController alloc] initWithPostID:self.post.pk];
    [self.navigationController pushViewController:commentController animated:YES];
}

- (void)onRefresh:(id)sender {
    if (SUPPORTS_WKWEBVIEW) {
        [(WKWebView *)self.webView reload];
    } else {
        [(UIWebView *)self.webView reload];
    }

    self.errorLabel.hidden = YES;
}

- (void)onBack:(id)sender {
    if (SUPPORTS_WKWEBVIEW) {
        [(WKWebView *)self.webView goBack];
    } else {
        [(UIWebView *)self.webView goBack];
    }
}

- (void)onForward:(id)sender {
    if (SUPPORTS_WKWEBVIEW) {
        [(WKWebView *)self.webView goForward];
    } else {
        [(UIWebView *)self.webView goForward];
    }
}

- (void)displayErrorLabel {
    [self hn_hideActivityIndicator];
    self.errorLabel.hidden = NO;
}

- (void)webViewFinishedLoading {
    [self hn_hideActivityIndicator];
    self.errorLabel.hidden = YES;
}

- (void)onTappedStatusBar:(id)sender {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController setToolbarHidden:NO animated:YES];
}


#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    self.title = webView.title.length ? webView.title : webView.URL.host;

    [self webViewFinishedLoading];

    self.backButton.enabled = webView.canGoBack;
    self.forwardButton.enabled = webView.canGoForward;
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
#if DEBUG
    NSLog(@"%@",error.localizedDescription);
#endif
    [self displayErrorLabel];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
#if DEBUG
    NSLog(@"%@",error.localizedDescription);
#endif
    [self displayErrorLabel];
}


#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    self.title = title.length ? title : webView.request.URL.host;

    [self hn_hideActivityIndicator];
    self.errorLabel.hidden = YES;

    self.backButton.enabled = webView.canGoBack;
    self.forwardButton.enabled = webView.canGoForward;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
#if DEBUG
    NSLog(@"%@",error.localizedDescription);
#endif
    [self hn_hideActivityIndicator];
    self.errorLabel.hidden = NO;
}

@end
