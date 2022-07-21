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

- (void) saveList: (ShoppingList *)list {
    [self saveInBackground];
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
    item.list = list;
    [list saveList:list];
    [item saveInBackgroundWithBlock:completion];
    //TODO: add failure logic for list + item
}

- (void) fetchItemsInList: (ShoppingList *)list withCompletion:(void(^)(NSArray *items, NSError *error))completion {
    PFQuery *query = [PFQuery queryWithClassName:@"Item"];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"list" equalTo:list];
    [query findObjectsInBackgroundWithBlock:^(NSArray *fetched_items, NSError *error) {
        completion(fetched_items, nil);
    }];
}
+ (void)fetchListsByUser: (PFUser *) user withCompletion:(void(^)(NSArray *lists, NSError *error))completion {
    PFQuery *query = [PFQuery queryWithClassName:@"ShoppingList"];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *fetched_lists, NSError *error) {
        completion(fetched_lists,nil);
    }];
}

@end
