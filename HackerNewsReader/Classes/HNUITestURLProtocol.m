//
//  HNUITestURLProtocol.m
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 6/10/15.
//  Copyright © 2015 Ryan Nystrom. All rights reserved.
//

#import "HNUITestURLProtocol.h"

@implementation HNUITestURLProtocol

+ (BOOL)canInitWithRequest:(nonnull NSURLRequest *)request {
    return [request.URL.absoluteString containsString:@"news.ycombinator.com"];
}

+ (BOOL)canInitWithTask:(nonnull NSURLSessionTask *)task {
    return [task.originalRequest.URL.absoluteString containsString:@"news.ycombinator.com"];
}

+ (NSURLRequest *)canonicalRequestForRequest:(nonnull NSURLRequest *)request {
    NSString *lastComponent = [[[request URL] pathComponents] lastObject];
    if ([lastComponent isEqualToString:@"news"]) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"front-page" ofType:@"html"];
        return [NSURLRequest requestWithURL:[NSURL URLWithString:path]];
    }
    return request;
}

- (void)startLoading {
    NSData *data = [[NSData alloc] initWithContentsOfFile:self.request.URL.absoluteString];
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:self.request.URL statusCode:200 HTTPVersion:nil headerFields:nil];
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    [self.client URLProtocol:self didLoadData:data];
    [self.client URLProtocolDidFinishLoading:self];
}

- (void)stopLoading {
    [self.client URLProtocolDidFinishLoading:self];
}

@end
