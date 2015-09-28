@import UIKit;

/** ATTENTION: Use this macro to access resources. */
#define HNResources ([__HNResources sharedInstance])

@interface __HNStoryboards : NSObject

- (UIStoryboard *)Main;

@end

@interface __HNTableViewCells : NSObject

- (NSString *)Cell;

@end

@interface __HNCollectionViewCells : NSObject


@end

@interface __HNViewControllers : NSObject

- (UIViewController *)Detail;
- (UIViewController *)TopTable;
- (UIViewController *)MasterNav;
- (UIViewController *)DetailNav;
- (UIViewController *)SplitViewRoot;

@end

@interface __HNSegues : NSObject


@end

/** Global resource reference accessor class. */
@interface __HNResources : NSObject

/** Singleton accessor. */
+ (instancetype)sharedInstance;

/** Resource accessors. */
@property (nonatomic, strong) __HNStoryboards *storyboards;
@property (nonatomic, strong) __HNTableViewCells *tableCells;
@property (nonatomic, strong) __HNCollectionViewCells *collectionCells;
@property (nonatomic, strong) __HNViewControllers *viewControllers;
@property (nonatomic, strong) __HNSegues *segues;

@end
