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

- (void) _updateSavedListWithNewItem: (PFObject *)item withCompletion:(void(^)(BOOL succeeded, NSError *error))completion {
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

- (void) _updateSavedListWithoutItem: (PFObject *)item withCompletion:(void(^)(BOOL succeeded, NSError *error))completion {
    NSMutableArray *previous_items = [NSMutableArray arrayWithArray:self.listObject[@"items"]];
    PFObject *item_to_delete = nil;
    for (PFObject *itemObject in previous_items) {
        NSLog(@"%@",item.objectId);
        NSLog(@"%@",itemObject.objectId);
        //NSLog(@"%@",itemObject[@"name"]);
        if([itemObject.objectId isEqual:item.objectId]) {
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
    [list fetchItemsInList:^(NSArray<Item *> * _Nonnull items, NSError * _Nonnull error) {
        NSMutableArray *const mutable_items = [NSMutableArray arrayWithArray:items];
        [mutable_items removeObject:item];
        ShoppingList *const newList = [[ShoppingList alloc] initWithStore_name:list.store_name items:[mutable_items copy]];
        newList.objectID = list.objectID;
        newList.listObject = list.listObject;
        [newList _updateSavedListWithoutItem:item.itemObject withCompletion:^(BOOL succeeded, NSError *error) {
                if(succeeded) {
                    completion(newList,nil);
                }
                else {
                    completion(nil,error);
                }
        }];
    }];
}


//add existing item to list



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
            NSLog(@"Error: %@",error);
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
            [newList _updateSavedListWithNewItem: item_to_save withCompletion:^(BOOL succeeded, NSError *error) {
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

//gets all items in this list
- (void) fetchItemsInList:(void(^)(NSArray<Item *> *items, NSError *error))completion {
    PFQuery *query = [PFQuery queryWithClassName:@"Item"];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"list" equalTo:self.listObject];
    [query findObjectsInBackgroundWithBlock:^(NSArray<PFObject *> *fetched_objects, NSError *error) {
        if(!error)
        {
            NSMutableArray<Item *> *new_items = [NSMutableArray new];
            for (PFObject *object in fetched_objects)
            {
                Item *const item_to_add = [Item createItemFromPFObject:object];
                [new_items addObject:item_to_add];
            }
            completion([NSArray arrayWithArray:new_items],nil);
        }
        else {
            completion(nil,error);
        }
        
    }];
}

//gets all lists by current user
+ (void)fetchListsByUser: (PFUser *) user withCompletion:(void(^)(NSArray<ShoppingList *> *lists, NSError *error))completion {
    PFQuery *query = [PFQuery queryWithClassName:@"ShoppingList"];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    dispatch_group_t fetchGroup = dispatch_group_create();
    [query findObjectsInBackgroundWithBlock:^(NSArray <ShoppingList *> *fetched_objects, NSError *error) {
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
    NSArray<PFObject *> *item_objects = object[@"items"];
    NSMutableArray<Item *> *items = [NSMutableArray new];
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
                NSLog(@"%@",error);
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
