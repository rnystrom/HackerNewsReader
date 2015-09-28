#import "HNResources.h"

/** UIStoryboard accessors. */
@implementation __HNStoryboards

- (UIStoryboard *)Main
{
	return [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
}

@end

/** UITableViewCell identifier accessors. */
@implementation __HNTableViewCells

- (NSString *)Cell
{
	return @"Cell";
}

@end

/** UICollectionViewCell identifier accessors. */
@implementation __HNCollectionViewCells


@end

/** UIViewController accessors. */
@implementation __HNViewControllers

- (UIViewController *)Detail
{
	return [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"Detail"];
}
- (UIViewController *)TopTable
{
	return [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"TopTable"];
}
- (UIViewController *)MasterNav
{
	return [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"MasterNav"];
}
- (UIViewController *)DetailNav
{
	return [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"DetailNav"];
}
- (UIViewController *)SplitViewRoot
{
	return [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"SplitViewRoot"];
}

@end

/** Segue identifier accessors. */
@implementation __HNSegues


@end

/** Main resource reference class. */
@implementation __HNResources

- (instancetype)init
{
    self = [super init];

    if (self) {
        self.storyboards = [[__HNStoryboards alloc] init];
        self.tableCells = [[__HNTableViewCells alloc] init];
        self.collectionCells = [[__HNCollectionViewCells alloc] init];
        self.viewControllers = [[__HNViewControllers alloc] init];
        self.segues = [[__HNSegues alloc] init];
    }

    return self;
}

+ (instancetype)sharedInstance
{
    static id _self = nil;
    static dispatch_once_t once_Token;
    dispatch_once(&once_Token, ^{
      _self = [[super alloc] init];
    });
    return _self;
}

@end
