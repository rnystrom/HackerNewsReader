//
//  HNWebViewController.m
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 4/6/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import "HNWebViewController.h"

#import <HackerNewsKit/HNPost.h>

#import <WebKit/WebKit.h>

#import <TUSafariActivity/TUSafariActivity.h>

#import "HNCommentViewController.h"
#import "UIColor+HackerNews.h"
#import "UIFont+HackerNews.h"
#import "TUSafariActivity.h"

#define SUPPORTS_WKWEBVIEW (NSClassFromString(@"WKWebView") != nil)

@interface HNWebViewController () <WKNavigationDelegate, UIWebViewDelegate>

@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@property (nonatomic, strong) UIView *webView;
@property (nonatomic, strong, readonly) HNPost *post;
@property (nonatomic, strong) UIView *statusBarBackgroundView;
@property (nonatomic, strong) UIBarButtonItem *backButton;
@property (nonatomic, strong) UIBarButtonItem *forwardButton;
@property (nonatomic, strong) UILabel *errorLabel;
@property (nonatomic, strong) UIBarButtonItem *shareBarButtonItem;

@end

@implementation HNWebViewController

- (instancetype)initWithPost:(HNPost *)post {
    if (self = [self initWithURL:post.URL]) {
        _post = post;
    }
    return self;
}

- (instancetype)initWithURL:(NSURL *)url {
    if (self = [super initWithCoder:nil]) {
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
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];

    self.view.backgroundColor = [UIColor whiteColor];

    CGRect bounds = self.view.bounds;

    self.webView.frame = bounds;
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.webView];

    self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityView.center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    self.activityView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.activityView startAnimating];
    self.activityView.hidesWhenStopped = YES;
    [self.view addSubview:self.activityView];

    self.statusBarBackgroundView = [[UIView alloc] initWithFrame:[UIApplication sharedApplication].statusBarFrame];
    self.statusBarBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.statusBarBackgroundView.backgroundColor = [self.navigationController.navigationBar.barTintColor colorWithAlphaComponent:0.95];
    [self.view addSubview:self.statusBarBackgroundView];

    self.errorLabel = [[UILabel alloc] init];
    self.errorLabel.hidden = YES;
    self.errorLabel.text = NSLocalizedString(@"Error loading page", @"There was an error loading the page");
    self.errorLabel.font = [UIFont titleFont];
    self.errorLabel.textColor = [UIColor subtitleTextColor];
    [self.errorLabel sizeToFit];
    self.errorLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.errorLabel.center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));;
    [self.view addSubview:self.errorLabel];

    self.backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backward"] style:UIBarButtonItemStylePlain target:self action:@selector(onBack:)];
    self.backButton.enabled = NO;
    self.forwardButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"forward"] style:UIBarButtonItemStylePlain target:self action:@selector(onForward:)];
    self.forwardButton.enabled = NO;
    UIBarButtonItem *refresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(onRefresh:)];
    UIBarButtonItem *share = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(onShare:)];
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

    if (self.post) {
        UIBarButtonItem *comments = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"chat"] style:UIBarButtonItemStylePlain target:self action:@selector(onComments:)];
        self.toolbarItems = @[self.backButton, flex, self.forwardButton, flex, refresh, flex, share, flex, comments];
    } else {
        self.toolbarItems = @[self.backButton, flex, self.forwardButton, flex, refresh, flex, share];
    }

    self.shareBarButtonItem = share;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if ([self.navigationController respondsToSelector:@selector(setHidesBarsOnSwipe:)]) {
        self.navigationController.hidesBarsOnSwipe = YES;
    }
    
    [self.navigationController setToolbarHidden:NO animated:animated];
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
    NSAssert(url != nil, @"Should always have a URL request");
    if (url) {
        TUSafariActivity *activity = [[TUSafariActivity alloc] init];
        UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[url] applicationActivities:@[activity]];
        if ([activityController respondsToSelector:@selector(popoverPresentationController)]) {
            activityController.popoverPresentationController.barButtonItem = self.shareBarButtonItem;
        }
        [self presentViewController:activityController animated:YES completion:nil];
    }
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

    [self.activityView startAnimating];
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
    [self.activityView stopAnimating];
    self.errorLabel.hidden = NO;
}

- (void)webViewFinishedLoading {
    [self.activityView stopAnimating];
    self.errorLabel.hidden = YES;
}


#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    self.title = webView.title;

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
    self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];

    [self.activityView stopAnimating];
    self.errorLabel.hidden = YES;

    self.backButton.enabled = webView.canGoBack;
    self.forwardButton.enabled = webView.canGoForward;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"%@",error);
    [self.activityView stopAnimating];
    self.errorLabel.hidden = NO;
}

@end
