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
#import "NSHTTPCookie+HackerNewsNetworker.h"
#import "NSHTTPCookieStorage+HackerNewsNetworker.h"

@implementation HNLogin

+ (void)loginUser:(NSString *)username
     withPassword:(NSString *)password
       completion:(void (^)(HNSession *, NSError *))completion {
    NSParameterAssert(completion != nil);
    NSParameterAssert(username.length > 0);
    NSParameterAssert(password.length > 0);

    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    [cookieStorage hn_clearAllCookies];

    NSURLSession *urlSession = [NSURLSession
                                sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                delegate:nil
                                delegateQueue:[NSOperationQueue mainQueue]];
    HNService *service = [[HNService alloc] initWithSession:urlSession path:@"login"];

    id completionHandler = ^(NSData *data, NSURLResponse *response, NSError *error) {
        HNSession *session = [cookieStorage hn_activeSession];
        completion(session, error);
    };

    NSDictionary *parameters = @{@"acct": username, @"pw": password};
    [service performRequest:@"POST" withParameters:parameters completion:completionHandler];
}

+ (BOOL)logoutCurrentUser:(void (^)(NSError*))completion {
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    HNSession *session = [cookieStorage hn_activeSession];

    const BOOL canLogout = session != nil;
    if (canLogout) {
        [cookieStorage hn_clearAllCookies];

        HNService *service = [[HNService alloc] initWithSession:nil path:@"logout"];
        [service fetchParameters:nil completion:^(id data, NSError *error) {
            if (completion) {
                completion(error);
            }
        }];
    }
    return canLogout;
}

@end
