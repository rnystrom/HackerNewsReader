//
//  HNSession.h
//  HackerNewsNetworker
//
//  Created by Ryan Nystrom on 1/10/16.
//  Copyright © 2016 Ryan Nystrom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HNSession : NSObject <NSCoding>

@property (nonatomic, strong, readonly) NSString *username;
@property (nonatomic, strong, readonly) NSString *session;

- (instancetype)initWithUsername:(NSString *)username session:(NSString *)session NS_DESIGNATED_INITIALIZER;

- (id)init NS_UNAVAILABLE;

@end
