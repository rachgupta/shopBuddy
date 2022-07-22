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

- (void) saveList {
    [self saveInBackground];
}
+ (void) createEmptyList:(NSString *)store_name withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    
    ShoppingList *newList = [ShoppingList new];
    newList.store_name = store_name;
    newList.user = [PFUser currentUser];
    newList.items = [NSArray new];
    [newList saveInBackgroundWithBlock: completion];
}
- (void) addItemToList: (Item *)item withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    NSMutableArray *const mutable_items = [NSMutableArray arrayWithArray:self.items];
    [mutable_items addObject:item];
    NSArray *array = [mutable_items copy];
    self.items = array;
    item.list = self;
    [self saveList];
    [item saveInBackgroundWithBlock:completion];
    //TODO: add failure logic for list + item
}

- (void) fetchItemsInList:(void(^)(NSArray<Item *> *items, NSError *error))completion {
    PFQuery *query = [PFQuery queryWithClassName:@"Item"];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"list" equalTo:self];
    [query findObjectsInBackgroundWithBlock:^(NSArray<Item *> *fetched_items, NSError *error) {
        completion(fetched_items, nil);
    }];
}

+ (void)fetchListsByUser: (PFUser *) user withCompletion:(void(^)(NSArray<ShoppingList *> *lists, NSError *error))completion {
    PFQuery *query = [PFQuery queryWithClassName:@"ShoppingList"];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray <ShoppingList *> *fetched_lists, NSError *error) {
        completion(fetched_lists,nil);
    }];
}

@end
