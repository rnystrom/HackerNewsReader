//
//  HNService.m
//  HackerNewsNetworker
//
//  Created by Ryan Nystrom on 4/5/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import "HNService.h"

#import "HNFeedParser.h"
#import "HNDiskStore.h"

@interface HNService ()

@property (nonatomic, strong, readonly) NSURLSession *session;
@property (nonatomic, strong, readonly) NSString *path;

@property (atomic, assign) NSUInteger tasksInFlight;

@end

@implementation HNService

- (instancetype)initWithSession:(NSURLSession *)session path:(NSString *)path {
    NSParameterAssert(path != nil);
    if (self = [super init]) {
        _session = session ?: [NSURLSession sharedSession];
        _path = [path copy];
    }
    return self;
}


#pragma mark - Fetching

- (BOOL)isFetching {
    return self.tasksInFlight > 0;
}

- (void)fetchParameters:(NSDictionary *)parameters completion:(void (^)(id, NSError*))completion {
    [self performRequest:@"GET" withParameters:parameters completion:^(NSData *data, NSURLResponse *response, NSError *error) {
        completion(data, error);
    }];
}

- (void)performRequest:(NSString *)method
        withParameters:(NSDictionary *)parameters
            completion:(void (^)(NSData*, NSURLResponse*, NSError*))completion {
    NSParameterAssert(method != nil);
    
    NSURLComponents *components = [[NSURLComponents alloc] initWithString:@"https://news.ycombinator.com"];

    NSString *path = self.path;
    if ([path characterAtIndex:0] != '/') {
        path = [@"/" stringByAppendingString:path];
    }
    [components setPath:path];
    
    NSMutableString *componentsString = [@"" mutableCopy];
    [parameters enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
        [componentsString appendFormat:@"%@=%@&",key,obj];
    }];
    
    NSString *httpBody = nil;
    if ([componentsString length] > 0) {
        if ([method isEqualToString:@"GET"]) {
            [components setQuery:componentsString];
        } else {
            httpBody = componentsString;
        }
    }
    
    NSURL *url = components.URL;
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = method;
    if (httpBody) {
        request.HTTPBody = [httpBody dataUsingEncoding:NSUTF8StringEncoding
                                  allowLossyConversion:NO];
    }
    
    NSURLSessionTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"%@",error);
        }
        
        self.tasksInFlight--;
        
        completion(data, response, error);
    }];
    
    // must call before -resume to avoid races
    self.tasksInFlight++;
    
    [task resume];
}

@end
