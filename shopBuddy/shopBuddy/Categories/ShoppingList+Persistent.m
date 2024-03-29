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
#import "AppState.h"

@implementation ShoppingList (Persistent)

- (NSString *)objectID {
    return objc_getAssociatedObject(self, @selector(objectID));
}

- (void)setObjectID:(NSString *)new_objectID {
    objc_setAssociatedObject(self, @selector(objectID), new_objectID, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSString *)listObject {
    return objc_getAssociatedObject(self, @selector(listObject));
}

- (void)setListObject:(NSString *)new_listObject {
    objc_setAssociatedObject(self, @selector(listObject), new_listObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void) _updateSavedListWithItem: (PFObject *)item withCompletion:(void(^)(BOOL succeeded, NSError *error))completion {
    NSMutableArray *previous_items = [NSMutableArray arrayWithArray:self.listObject[@"items"]];
    [previous_items addObject:item];
    self.listObject[@"items"] = [NSArray arrayWithArray:previous_items];
    [self.listObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        if(succeeded) {
            completion(succeeded, nil);
        }
        else {
            completion(NO, error);
        }
    }];
}

- (void) _updateSavedListWithoutItemID: (NSString *)itemID withCompletion:(void(^)(BOOL succeeded, NSError *error))completion{
    NSMutableArray *const previous_items = [NSMutableArray arrayWithArray:self.listObject[@"items"]];
    PFObject *item_to_delete = nil;
    for (PFObject *itemObject in previous_items) {
        if([itemObject.objectId isEqual:itemID]) {
            item_to_delete = itemObject;
        }
    }
    [previous_items removeObject:item_to_delete];
    self.listObject[@"items"] = [NSArray arrayWithArray:previous_items];
    [self.listObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        if(succeeded) {
            completion(succeeded, nil);
        }
        else {
            completion(NO, error);
        }
    }];
}

//remove existing item from list
+ (void) removeItemFromList: (ShoppingList *)list withItem: (Item *)item withCompletion:(void(^)(ShoppingList *new_list,NSError *error))completion {
    NSMutableArray<Item *> *const mutable_items = [NSMutableArray arrayWithArray:list.items];
    [mutable_items removeObject:item];
    ShoppingList *const newList = [[ShoppingList alloc] initWithStore_name:list.store_name items:[mutable_items copy]];
    newList.objectID = list.objectID;
    newList.listObject = list.listObject;
    [newList _updateSavedListWithoutItemID:item.objectID withCompletion:^(BOOL succeeded, NSError *error) {
        if(succeeded) {
            completion(newList,nil);
        }
        else {
            completion(nil,error);
        }
    }];
}


//add existing item to list
+ (void) addExistingItem:(Item *)item toList:(ShoppingList *)list withCompletion:(void(^)(Item *item, NSError *error))completion {
    item.itemObject[@"list"] = list.listObject;
    [item.itemObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(succeeded) {
            NSMutableArray *const mutable_items = [NSMutableArray arrayWithArray:list.items];
            [mutable_items addObject:item];
            ShoppingList *const newList = [[ShoppingList alloc] initWithStore_name:list.store_name items:[mutable_items copy]];
            newList.objectID = list.objectID;
            newList.listObject = list.listObject;
            item.itemObject.objectId = item.objectID;
            [newList _updateSavedListWithItem:item.itemObject withCompletion:^(BOOL succeeded, NSError *error) {
                if(!error) {
                    completion(item,nil);
                }
                else {
                    completion(nil,error);
                }
            }];
        }
        else {
            completion(nil,error);
        }
    }];
}



//Used to create new lists
+ (void) createEmptyList:(NSString *)store_name withCompletion:(void(^)(ShoppingList *new_list,NSError *error))completion {
    NSDictionary *const dict = @{ @"user" : [PFUser currentUser], @"items" : [NSArray new], @"store_name" : store_name};
    PFObject *new_object = [PFObject objectWithClassName:@"ShoppingList" dictionary:dict];
    [new_object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        if(succeeded) {
            [ShoppingList _hydrateShoppingListFromPFObject:new_object withCompletion:^(ShoppingList *list, NSError *error) {
                if(!error) {
                    completion(list,nil);
                }
                else {
                    completion(nil,error);
                }
            }];
        }
        else {
            completion(nil,error);
        }
    }];
}

//add items to list
+ (void) createFromList:(ShoppingList *)list withItem:(Item *)item withCompletion:(void(^)(ShoppingList* updatedList, NSError *error))completion {
    NSMutableArray *const mutable_items = [NSMutableArray arrayWithArray:list.items];
    [mutable_items addObject:item];
    ShoppingList *const newList = [[ShoppingList alloc] initWithStore_name:list.store_name items:[mutable_items copy]];
    newList.objectID = list.objectID;
    newList.listObject = list.listObject;
    PFObject *item_to_save = [item hydratePFObjectFromItemWithListObject:newList.listObject];
    [item_to_save saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        if(succeeded) {
            item.itemObject = item_to_save;
            [newList _updateSavedListWithItem: item_to_save withCompletion:^(BOOL succeeded, NSError *error) {
                    if(succeeded) {
                        completion(newList,nil);
                    }
                    else {
                        completion(nil,error);
                    }
            }];
        }
        else {
            completion(nil,error);
        }
    }];
}

//gets all lists by current user
+ (void)fetchLists:(void(^)(NSArray<ShoppingList *> *lists, NSError *error))completion {
    PFQuery *const query = [PFQuery queryWithClassName:@"ShoppingList"];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    dispatch_group_t fetchGroup = dispatch_group_create();
    [query findObjectsInBackgroundWithBlock:^(NSArray <PFObject *> *fetched_objects, NSError *error) {
        NSMutableArray<ShoppingList *> *new_lists = [NSMutableArray new];
        for (PFObject *object in fetched_objects)
        {
            dispatch_group_enter(fetchGroup);
            [ShoppingList _hydrateShoppingListFromPFObject:object withCompletion:^(ShoppingList *list, NSError *error) {
                if(!error) {
                    [new_lists addObject:list];
                    dispatch_group_leave(fetchGroup);
                }
                else {
                    completion(nil,error);
                }
            }];
        }
        dispatch_group_notify(fetchGroup,dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ {
            AppState *myAppState = [AppState sharedManager];
            myAppState.lists = new_lists;
            completion([NSArray arrayWithArray:new_lists],nil);
        });
    }];
}

//makes a list to house a given list object
+ (void)_hydrateShoppingListFromPFObject: (PFObject *)object withCompletion:(void(^)(ShoppingList * list, NSError *error))completion {
    NSArray<PFObject *> * const item_objects = object[@"items"];
    NSMutableArray<Item *> *const items = [NSMutableArray new];
    dispatch_group_t group = dispatch_group_create();
    for (PFObject* item_object in item_objects){
        dispatch_group_enter(group);
        PFQuery *query = [PFQuery queryWithClassName:@"Item"];
        [query getObjectInBackgroundWithId:item_object.objectId block:^(PFObject *full_item_object, NSError *error){
            if(!error) {
                Item *new_item = [Item createItemFromPFObject:full_item_object];
                [items addObject:new_item];
                dispatch_group_leave(group);
            }
            else {
                completion(nil,error);
            }
        }];
    }
    dispatch_group_notify(group,dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ {
        ShoppingList *const newList = [[ShoppingList alloc] initWithStore_name:object[@"store_name"] items:[NSArray arrayWithArray:items]];
        newList.listObject = object;
        newList.objectID = object.objectId;
        completion(newList,nil);
    });
}


@end
