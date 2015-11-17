//
//  HNLogin.m
//  HackerNewsNetworker
//
//  Created by Stanislav Sidelnikov on 17/11/15.
//  Copyright © 2015 Ryan Nystrom. All rights reserved.
//

#import "HNLogin.h"

@implementation HNLogin

+ (BOOL)isLoggedIn {
    return NO;
}

- (BOOL)loginUser:(NSString *)username
     withPassword:(NSString *)password
       completion:(void (^)(NSString *, NSError *))completion {
    if ([self.class isLoggedIn]) {
        [self.class logoutCurrentUser];
    }
    
    NSString *urlString = @"https://news.ycombinator.com/login";
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    request.HTTPMethod = @"POST";
    
    NSDictionary *parameters = @{@"acct": username, @"pw": password};
    NSMutableString *components = [@"" mutableCopy];
    [parameters enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
        [components appendFormat:@"%@=%@&",key,obj];
    }];
    request.HTTPBody = [components dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
    
    NSURLSession *urlSession = [NSURLSession
                                sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]
                                delegate:self
                                delegateQueue:[NSOperationQueue mainQueue]];
    
    id completionHandler = ^(NSData *data, NSURLResponse *response, NSError *error) {
        if (response && [response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            NSArray *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:httpResponse.allHeaderFields
                                                                      forURL:response.URL];
            for (NSHTTPCookie *cookie in cookies) {
                NSLog(@"Cookie[\"%@\"] = \"%@\";", cookie.name, cookie.value);
            }
        }
    };
    
    NSURLSessionDataTask *task = [urlSession dataTaskWithRequest:request
                                               completionHandler:completionHandler];
    
    [task resume];
    
    return NO;
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
willPerformHTTPRedirection:(NSHTTPURLResponse *)response
        newRequest:(NSURLRequest *)request
 completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler {
    completionHandler(nil);
}

+ (BOOL)logoutCurrentUser {
    BOOL result = NO;
    if ([self.class isLoggedIn]) {
        
    }
    return result;
}

@end
