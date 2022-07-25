//
//  ShoppingList+Persistent.m
//  shopBuddy
//
//  Created by Rachna Gupta on 7/21/22.
//

#import "ShoppingList+Persistent.h"
#import "Item.h"
#import "ShoppingList.h"
#import "Parse/Parse.h"
#import "Item+Persistent.h"
#import <objc/runtime.h>

@implementation ShoppingList (Persistent)

+ (void) _createObject:(PFObject *)object {
    [object saveInBackground];
}

- (NSString *)objectID {
    return objc_getAssociatedObject(self, @selector(objectID));
}

- (void)setObjectID:(NSString *)new_objectID {
    objc_setAssociatedObject(self, @selector(objectID), new_objectID, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void) _updateSavedListWithNewItem: (PFObject *)item {
    PFQuery *query = [PFQuery queryWithClassName:@"ShoppingList"];
    [query getObjectInBackgroundWithId:self.objectID block:^(PFObject *list_object, NSError *error) {
        if (!error) {
            NSMutableArray *previous_items = [NSMutableArray arrayWithArray:list_object[@"items"]];
            [previous_items addObject:item];
            list_object[@"items"] = [NSArray arrayWithArray:previous_items];
            [list_object saveInBackground];
        } else {
            NSLog(@"%@",error);
        }
    }];
}

//Used to create new lists
+ (void) createEmptyList:(NSString *)store_name withCompletion:(void(^)(ShoppingList *new_list))completion {
    NSDictionary *dict = @{ @"user" : [PFUser currentUser], @"items" : [NSArray new], @"store_name" : store_name};
    PFObject *new_object = [PFObject objectWithClassName:@"ShoppingList" dictionary:dict];
    [ShoppingList _createObject:new_object];
    ShoppingList *const newList = [ShoppingList _hydrateShoppingListFromPFObject:new_object];
    completion(newList);
    
}

+ (void) addItemToList: (Item *)item withList: (ShoppingList *)list {
    NSMutableArray *const mutable_items = [NSMutableArray arrayWithArray:list.items];
    [mutable_items addObject:item];
    //NSArray *array = [mutable_items copy];
    ShoppingList *const newList = [[ShoppingList alloc] initWithStore_name:list.store_name items:[mutable_items copy]];
    newList.objectID = list.objectID;
    PFObject *item_to_save = [item hydratePFObjectFromItemWithListObject:[newList _retrievePFObject]];
    [item_to_save saveInBackground];
    [newList _updateSavedListWithNewItem: item_to_save];
}

//gets the PFObject from the database associated with this List
- (PFObject*)_retrievePFObject {
    PFQuery *query = [PFQuery queryWithClassName:@"ShoppingList"];
    return [query getObjectWithId:self.objectID];
}

//gets all items in this list
- (void) fetchItemsInList:(void(^)(NSArray<Item *> *items, NSError *error))completion {
    PFObject *const list_object = [self _retrievePFObject];
    PFQuery *query = [PFQuery queryWithClassName:@"Item"];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"list" equalTo:list_object];
    [query findObjectsInBackgroundWithBlock:^(NSArray<PFObject *> *fetched_objects, NSError *error) {
        NSMutableArray<Item *> *new_items = [NSMutableArray new];
        for (PFObject *object in fetched_objects)
        {
            Item *const item_to_add = [Item createItemFromPFObject:object];
            [new_items addObject:item_to_add];
        }
        completion([NSArray arrayWithArray:new_items],nil);
        
    }];
}

//gets all lists by current user
+ (void)fetchListsByUser: (PFUser *) user withCompletion:(void(^)(NSArray<ShoppingList *> *lists, NSError *error))completion {
    PFQuery *query = [PFQuery queryWithClassName:@"ShoppingList"];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray <ShoppingList *> *fetched_objects, NSError *error) {
        NSMutableArray<ShoppingList *> *new_lists = [NSMutableArray new];
        for (PFObject *object in fetched_objects)
        {
            ShoppingList *const list_to_add = [ShoppingList _hydrateShoppingListFromPFObject:object];
            [new_lists addObject:list_to_add];
        }
        completion([NSArray arrayWithArray:new_lists],nil);
    }];
}

//makes a list to house a given list object
+ (ShoppingList*)_hydrateShoppingListFromPFObject: (PFObject *)object {
    NSLog(@"%@",object.objectId);
    NSArray<PFObject *> *item_objects = object[@"items"];
    NSMutableArray<Item *> *items = [NSMutableArray new];
    for (PFObject* item_object in item_objects){
        PFObject *full_item_object = [Item populateObjectFromPointerObject:item_object];
        Item *new_item = [Item createItemFromPFObject:full_item_object];
        [items addObject:new_item];
    }
    ShoppingList *const newList = [[ShoppingList alloc] initWithStore_name:object[@"store_name"] items:[NSArray arrayWithArray:items]];
    newList.objectID = object.objectId;
    return newList;
}


@end
