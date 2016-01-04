//
//  HNQueries.m
//  HackerNewsNetworker
//
//  Created by Ryan Nystrom on 1/3/16.
//  Copyright © 2016 Ryan Nystrom. All rights reserved.
//

#import "HNQueries.h"

@implementation HNQueries

static HNQueries *_sharedQueries = nil;

+ (NSString *)cachePath {
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    return [docPath stringByAppendingPathComponent:@"cached-queries.json"];
}

+ (NSString *)fallbackPath {
    return [[NSBundle bundleForClass:self] pathForResource:@"fallback-queries" ofType:@"json"];
}

+ (HNQueries *)localQueries {
    NSString *cachePath = [self cachePath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *localPath;
    if ([fileManager fileExistsAtPath:cachePath]) {
        localPath = cachePath;
    } else {
        localPath = [self fallbackPath];
    }
    NSData *data = [[NSData alloc] initWithContentsOfFile:localPath];
    if (data.length == 0) {
        NSLog(@"No data found for local queries.");
        abort();
    }
    NSError *error = nil;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error) {
        NSLog(@"%@",error.localizedDescription);
        abort();
    }
    return [[HNQueries alloc] initWithDictionary:dictionary];
}

+ (void)loadRemoteQueries {
    NSURL *URL = [NSURL URLWithString:@"http://whoisryannystrom.com/hackernews.json"];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithURL:URL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"%@",error.localizedDescription);
            return;
        }
        if (!data) {
            NSLog(@"No data for parsing queries request.");
            return;
        }
        NSError *parsingError = nil;
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parsingError];
        if (parsingError) {
            NSLog(@"%@",parsingError.localizedDescription);
            NSLog(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            return;
        }
        if (!dictionary) {
            NSLog(@"No dictionary deserializing query JSON object.");
            return;
        }
        HNQueries *queries = [[HNQueries alloc] initWithDictionary:dictionary];
        @synchronized(self) {
            _sharedQueries = queries;
        }

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSError *writeError = nil;
            [data writeToFile:[self cachePath] options:0 error:&writeError];
            if (writeError) {
                NSLog(@"%@",writeError.localizedDescription);
            }
        });
    }];
    [task resume];
}

+ (HNQueries *)sharedQueries {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        HNQueries *queries;
        @synchronized(self) {
            queries = _sharedQueries;
        }
        if (!queries) {
            queries = [self localQueries];
        }
        @synchronized(self) {
            if (!_sharedQueries) {
                _sharedQueries = queries;
            }
        }
    });
    @synchronized(self) {
        return _sharedQueries;
    }
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        NSDictionary *feed = dictionary[@"feed"];
        _feedTitles = feed[@"titles"];
        _feedDetails = feed[@"details"];
        _feedScore = feed[@"score"];
        _feedCommentNode = feed[@"comment_node"];

        NSDictionary *comment = dictionary[@"comments"];
        _commentComments = comment[@"comments"];
        _commentUser = comment[@"user"];
        _commentText = comment[@"test"];
        _commentRemoved = comment[@"removed"];
        _commentIndent = comment[@"indent"];
        _commentPermalink = comment[@"permalink"];

        NSDictionary *page = dictionary[@"page"];
        _pageText = page[@"text"];
    }
    return self;
}

@end
