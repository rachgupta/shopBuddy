//
//  ShoppingList+Persistent.m
//  shopBuddy
//
//  Created by Rachna Gupta on 7/21/22.
//

#import "ShoppingList+Persistent.h"
#import "Item.h"
#import "ShoppingList.h"

@implementation ShoppingList (Persistent)

- (void) saveList: (ShoppingList *)list{
    [list saveInBackground];
}
+ (void) createEmptyList:(NSString *)store_name withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    
    ShoppingList *newList = [ShoppingList new];
    newList.store_name = store_name;
    newList.user = [PFUser currentUser];
    newList.items = [NSArray new];
    [newList saveInBackgroundWithBlock: completion];
}
- (void) addItemToList: (Item *)item withList: (ShoppingList *)list withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    NSMutableArray *const mutable_items = [NSMutableArray arrayWithArray:list.items];
    [mutable_items addObject:item];
    NSArray *array = [mutable_items copy];
    list.items = array;
    item.list = self;
    [list saveList: list];
    [item saveInBackgroundWithBlock: completion];
    NSString *test = @"hello";
    
}

@end
