//
//  UITableView+DataDiffing.m
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 4/11/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import "UITableView+DataDiffing.h"

@implementation UITableView (DataDiffing)

- (void)performUpdatesWithOldArray:(NSArray *)oldArray
                          newArray:(NSArray *)newArray
                           section:(NSInteger)section
             dataSourceUpdateBlock:(void (^)(NSMutableArray*,NSMutableArray*,NSMutableArray*))dataSourceUpdateBlock {
    NSAssert(dataSourceUpdateBlock != nil, @"Insert/delete will be out of sync with your data source. Make sure to update your data.");

    BOOL hadItems = oldArray.count > 0;
    NSMutableArray *inserts = [[NSMutableArray alloc] init];
    NSMutableArray *reloads = [[NSMutableArray alloc] init];
    [newArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSUInteger foundIdx = [oldArray indexOfObject:obj];
        if (!hadItems || foundIdx != idx) {
            [inserts addObject:[NSIndexPath indexPathForRow:idx inSection:section]];
        } else {
            [reloads addObject:[NSIndexPath indexPathForRow:idx inSection:section]];
        }
    }];

    BOOL hasItems = newArray.count > 0;
    NSMutableArray *deletes = [[NSMutableArray alloc] init];
    [oldArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSUInteger foundIdx = [newArray indexOfObject:obj];
        if (!hasItems || foundIdx != idx) {
            [deletes addObject:[NSIndexPath indexPathForRow:idx inSection:section]];
        }
    }];

    dataSourceUpdateBlock(inserts, deletes, reloads);

    [self beginUpdates];
    [self insertRowsAtIndexPaths:inserts withRowAnimation:UITableViewRowAnimationFade];
    [self deleteRowsAtIndexPaths:deletes withRowAnimation:UITableViewRowAnimationFade];
    [self reloadRowsAtIndexPaths:reloads withRowAnimation:UITableViewRowAnimationFade];
    [self endUpdates];
}

@end
