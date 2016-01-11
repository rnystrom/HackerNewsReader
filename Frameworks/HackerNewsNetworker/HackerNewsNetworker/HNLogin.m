//
//  HNLogin.m
//  HackerNewsNetworker
//
//  Created by Stanislav Sidelnikov on 17/11/15.
//  Copyright © 2015 Ryan Nystrom. All rights reserved.
//

#import "HNLogin.h"
#import "HNService.h"
#import "HNSession.h"
#import "NSHTTPCookie+HackerNews.h"
#import "NSHTTPCookieStorage+HackerNews.h"

@implementation HNLogin

+ (NSHTTPCookie *)getUserLogin {
    NSURL *url = [NSURL URLWithString:@"https://news.ycombinator.com"];
    NSArray *cookiesArray = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:url];
    NSHTTPCookie *userCookie = nil;
    for (NSHTTPCookie *cookie in cookiesArray) {
        if ([cookie.name isEqual: @"user"]) {
            userCookie = cookie;
            break;
        }
    }
    return userCookie;
}

+ (NSString *)currentUserLogin {
    NSHTTPCookie *userCookie = [self.class getUserLogin];
    return [userCookie name];
}

+ (BOOL)isLoggedIn {
    return [self.class getUserLogin] != nil;
}

+ (void)loginUser:(NSString *)username
     withPassword:(NSString *)password
       completion:(void (^)(HNSession *, NSError *))completion {
    NSParameterAssert(completion != nil);

    NSURLSession *urlSession = [NSURLSession
                                sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                delegate:nil
                                delegateQueue:[NSOperationQueue mainQueue]];
    HNService *service = [[HNService alloc] initWithSession:urlSession path:@"login"];
    
    NSDictionary *parameters = @{@"acct": username, @"pw": password};
    id completionHandler = ^(NSData *data, NSURLResponse *response, NSError *error) {
        if (response && [response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            NSArray *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:httpResponse.allHeaderFields
                                                                      forURL:response.URL];
            HNSession *session = nil;
            for (NSHTTPCookie *cookie in cookies) {
                NSString *username = [cookie hackerNewsUsername];
                NSString *sessionKey = [cookie hackerNewsSession];
                if (username.length && sessionKey.length) {
                    session = [[HNSession alloc] initWithUsername:username session:sessionKey];
                    break;
                }
            }

            completion(session, error);
        }
    };
    [service performRequest:@"POST" withParameters:parameters completion:completionHandler];
}

- (BOOL)logoutCurrentUser:(void (^)(NSError*))completion {
    BOOL result = NO;
    if ([self.class isLoggedIn]) {
        HNService *service = [[HNService alloc] initWithSession:nil path:@"logout"];
        
        [service fetchParameters:nil completion:^(id data, NSError *error) {
            if (completion) {
                completion(error);
            }
        }];
        
        result = YES;
    }
    return result;
}

#pragma mark - NSURLSessionTask delegate

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
willPerformHTTPRedirection:(NSHTTPURLResponse *)response
        newRequest:(NSURLRequest *)request
 completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler {
    completionHandler(nil);
}

@end
