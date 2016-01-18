//
//  HNService.h
//  HackerNewsNetworker
//
//  Created by Ryan Nystrom on 4/5/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface HNService : NSObject

- (instancetype)initWithSession:(nullable NSURLSession *)session path:(NSString *)path NS_DESIGNATED_INITIALIZER;

- (void)fetchParameters:(nullable NSDictionary *)parameters completion:(nullable void (^)(id, NSError*))completion;

- (void)performRequest:(NSString *)method
        withParameters:(NSDictionary *)parameters
            completion:(nullable void (^)(NSData*, NSURLResponse*, NSError*))completion;

- (BOOL)isFetching;

- (id)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
