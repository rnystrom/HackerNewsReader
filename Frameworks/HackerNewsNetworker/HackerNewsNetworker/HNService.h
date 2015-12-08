//
//  HNService.h
//  HackerNewsNetworker
//
//  Created by Ryan Nystrom on 4/5/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

@import Foundation;

@interface HNService : NSObject

- (instancetype)initWithSession:(NSURLSession *)session path:(NSString *)path NS_DESIGNATED_INITIALIZER;

- (void)fetchParameters:(NSDictionary *)parameters completion:(void (^)(id, NSError*))completion;

- (void)performRequest:(NSString *)method
        withParameters:(NSDictionary *)parameters
            completion:(void (^)(NSData*, NSURLResponse*, NSError*))completion;

- (BOOL)isFetching;

@end
