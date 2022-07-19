/**
 * This file is generated using the remodel generation script.
 * The name of the input file is ShoppingList.value
 */

#if  ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

#import "ShoppingList.h"
#import "Item.h"

@implementation ShoppingList

@dynamic store_name;
@dynamic items;
@dynamic user;

+ (nonnull NSString *)parseClassName {
    return @"ShoppingList";
}
+ (void) createList:(NSString *)store_name withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    
    ShoppingList *newList = [ShoppingList new];
    newList.store_name = store_name;
    newList.user = [PFUser currentUser];
    newList.items = [NSMutableArray new];
    
    [newList saveInBackgroundWithBlock: completion];
}
- (void) refreshPost {
    [self saveInBackground];
}


@end
