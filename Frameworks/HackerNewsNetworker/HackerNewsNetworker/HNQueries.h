//
//  HNQueries.h
//  HackerNewsNetworker
//
//  Created by Ryan Nystrom on 1/3/16.
//  Copyright © 2016 Ryan Nystrom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HNQueries : NSObject

+ (void)loadRemoteQueries;

+ (HNQueries *)sharedQueries;

@property (nonatomic, strong, readonly) NSString *feedTitles;
@property (nonatomic, strong, readonly) NSString *feedDetails;
@property (nonatomic, strong, readonly) NSString *feedScore;
@property (nonatomic, strong, readonly) NSString *feedCommentNode;

@property (nonatomic, strong, readonly) NSString *commentComments;
@property (nonatomic, strong, readonly) NSString *commentUser;
@property (nonatomic, strong, readonly) NSString *commentText;
@property (nonatomic, strong, readonly) NSString *commentRemoved;
@property (nonatomic, strong, readonly) NSString *commentIndent;
@property (nonatomic, strong, readonly) NSString *commentPermalink;

@property (nonatomic, strong, readonly) NSString *pageText;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary NS_DESIGNATED_INITIALIZER;

- (id)init NS_UNAVAILABLE;

@end
