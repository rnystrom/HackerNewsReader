//
//  UITableView+DataDiffing.h
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 4/11/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (DataDiffing)

- (void)performUpdatesWithOldArray:(NSArray *)oldArray
                          newArray:(NSArray *)newArray
                           section:(NSInteger)section
             dataSourceUpdateBlock:(void (^)(NSMutableArray *inserts, NSMutableArray *deletes, NSMutableArray *reloads))dataSourceUpdateBlock;

@end
