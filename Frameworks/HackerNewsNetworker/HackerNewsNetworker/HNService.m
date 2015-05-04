//
//  HNService.m
//  HackerNewsNetworker
//
//  Created by Ryan Nystrom on 4/5/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import "HNService.h"

#import "HNFeedParser.h"
#import "HNStore.h"

@interface HNService ()

@property (nonatomic, strong, readonly) NSURLSession *session;
@property (nonatomic, strong, readonly) NSString *path;
@property (atomic, assign) NSUInteger tasksInFlight;

@end

@implementation HNService

- (instancetype)initWithSession:(NSURLSession *)session path:(NSString *)path {
    if (self = [super init]) {
        _session = session ?: [NSURLSession sharedSession];
        _path = [path copy];
    }
    return self;
}

- (instancetype)init {
    return [self initWithSession:nil path:nil];
}


#pragma mark - Fetching

- (BOOL)isFetching {
    return self.tasksInFlight > 0;
}

- (void)fetchParameters:(NSDictionary *)parameters completion:(void (^)(id, NSError*))completion {
    NSAssert(completion != nil, @"Why are you executing a network request without doing anything with the data?");

    NSString *urlString = @"https://news.ycombinator.com";
    if (self.path) {
        urlString = [urlString stringByAppendingPathComponent:self.path];
    }

    NSMutableString *components = [@"?" mutableCopy];
    [parameters enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
        [components appendFormat:@"%@=%@",key,obj];
    }];

    urlString = [urlString stringByAppendingString:components];
    NSURL *url = [NSURL URLWithString:urlString];

    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    NSURLSessionTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
#ifdef DEBUG
        if (error) {
            NSLog(@"%@",error);
        }
#endif

        self.tasksInFlight--;

        completion(data, error);
    }];

    // must call before -resume to avoid races
    self.tasksInFlight++;

    [task resume];
}

- (void)fetchKey:(NSUInteger)key completion:(void (^)(id <NSCoding>, NSError*))completion {
    // subclass override
}

@end
