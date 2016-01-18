//
//  HNDataCoordinator.m
//  HackerNewsNetworker
//
//  Created by Ryan Nystrom on 4/6/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import "HNDataCoordinator.h"

#import "HNFeedParser.h"
#import "HNDiskStore.h"
#import "HNService.h"

static NSString * const kHNDataCoordinatorDidSaveNotification = @"kHNDataCoordinatorDidSaveNotification";

@interface HNDataCoordinator ()

@property (nonatomic, strong, readonly) HNDiskStore *store;
@property (atomic, assign, getter=hasLoadedOnce) BOOL loadedOnce;
@property (nonatomic, strong, readonly) NSNotificationCenter *notificationCenter;

@end

@implementation HNDataCoordinator

- (void)dealloc {
    [_notificationCenter removeObserver:self];
}

- (instancetype)initWithDelegate:(id <HNDataCoordinatorDelegate>)delegate
                   delegateQueue:(dispatch_queue_t)delegateQueue
                            path:(NSString *)path
                          parser:(id <HNParseProtocol>)parser
                       cacheName:(NSString *)cacheName {
    NSParameterAssert(delegate != nil);
    NSParameterAssert(delegateQueue != nil);
    NSParameterAssert(path != nil);
    NSParameterAssert(parser != nil);
    NSParameterAssert(cacheName != nil);
    if (self = [super init]) {
        _store = [[HNDiskStore alloc] initWithCacheName:cacheName];
        _service = [[HNService alloc] initWithSession:[NSURLSession sharedSession] path:path];
        _parser = parser;
        _delegate = delegate;
        _delegateQueue = delegateQueue ?: dispatch_get_main_queue();

        _notificationCenter = [NSNotificationCenter defaultCenter];
        [_notificationCenter addObserver:self selector:@selector(onStoreUpdated:) name:[self notificationName] object:nil];
    }
    return self;
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
                    [_notificationCenter postNotificationName:[self notificationName] object:self];
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
