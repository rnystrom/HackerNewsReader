//
//  HNDataCoordinator.m
//  HackerNewsNetworker
//
//  Created by Ryan Nystrom on 4/6/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import "HNDataCoordinator.h"

#import "HNFeedParser.h"
#import "HNStore.h"
#import "HNService.h"

static NSString * const kHNDataCoordinatorDidSaveNotification = @"kHNDataCoordinatorDidSaveNotification";

@interface HNDataCoordinator ()

@property (nonatomic, strong, readonly) HNStore *store;
@property (atomic, assign, getter=hasLoadedOnce) BOOL loadedOnce;

@end

@implementation HNDataCoordinator

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithDelegate:(id <HNDataCoordinatorDelegate>)delegate
                   delegateQueue:(dispatch_queue_t)delegateQueue
                            path:(NSString *)path
                          parser:(id <HNParseProtocol>)parser
                       cacheName:(NSString *)cacheName {
    if (self = [super init]) {
        _store = [[HNStore alloc] initWithCacheName:cacheName];
        _service = [[HNService alloc] initWithSession:[NSURLSession sharedSession] path:path];
        _parser = parser;
        _delegate = delegate;
        _delegateQueue = delegateQueue ?: dispatch_get_main_queue();

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onStoreUpdated:) name:[self notificationName] object:nil];
    }
    return self;
}

- (instancetype)init {
    NSAssert(NO, @"Cannot initialize a data coordinator without a cache");
    return [self initWithDelegate:nil delegateQueue:nil path:nil parser:nil cacheName:nil];
}

- (NSString *)notificationName {
    return self.cacheName;
}


#pragma mark - Getters

- (BOOL)isFetching {
    return [self.service isFetching];
}

- (NSString *)cacheName {
    return self.store.cachePath;
}


#pragma mark - Fetching

- (void)fetch {
    [self fetchWithParams:nil];
}

- (void)fetchWithParams:(NSDictionary *)params {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.service fetchParameters:params completion:^(id data, NSError *error) {
            self.loadedOnce = YES;
            if (error && [self.delegate respondsToSelector:@selector(dataCoordinator:didError:)]) {
                dispatch_async(self.delegateQueue, ^{
                    [self.delegate dataCoordinator:self didError:error];
                });
            } else if (data) {
                HNQueries *queries = [HNQueries sharedQueries];
                id object = [self.parser parseDataFromResponse:data queries:queries];
                if (object && [self.store archiveToDisk:object]) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:[self notificationName] object:self];
                    dispatch_async(self.delegateQueue, ^{
                        [self.delegate dataCoordinator:self didUpdateObject:object];
                    });
                }
            }
        }];
    });
}


#pragma mark - Notifications

- (void)onStoreUpdated:(NSNotification *)notification {
    if (notification.object != self) {
        id <NSCoding> object = [self.store fetchFromDisk];
        dispatch_async(self.delegateQueue, ^{
            [self.delegate dataCoordinator:self didUpdateObject:object];
        });
    }
}

@end
