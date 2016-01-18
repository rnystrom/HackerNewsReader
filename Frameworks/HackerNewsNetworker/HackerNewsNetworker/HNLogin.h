//
//  HNLogin.h
//  HackerNewsNetworker
//
//  Created by Stanislav Sidelnikov on 17/11/15.
//  Copyright © 2015 Ryan Nystrom. All rights reserved.
//

@import Foundation;

@class HNSession;

NS_ASSUME_NONNULL_BEGIN

@interface HNLogin : NSObject

+ (void)loginUser:(NSString *)username
     withPassword:(NSString *)password
       completion:(void (^)(HNSession*, NSError*))completion;

+ (BOOL)logoutCurrentUser:(void (^)(NSError*))completion;

@end

NS_ASSUME_NONNULL_END
