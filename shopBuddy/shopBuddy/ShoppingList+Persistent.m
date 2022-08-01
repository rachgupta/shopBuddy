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
            NSLog(@"Error Updating List: %@",error);
            completion(NO, error);
        }
    }];
}

//Used to create new lists
+ (void) createEmptyList:(NSString *)store_name withCompletion:(void(^)(ShoppingList *new_list,NSError *error))completion {
    NSDictionary *const dict = @{ @"user" : [PFUser currentUser], @"items" : [NSArray new], @"store_name" : store_name};
    PFObject *new_object = [PFObject objectWithClassName:@"ShoppingList" dictionary:dict];
    [new_object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        if(succeeded) {
            ShoppingList *const newList = [ShoppingList _hydrateShoppingListFromPFObject:new_object];
            completion(newList,nil);
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
    [query findObjectsInBackgroundWithBlock:^(NSArray <ShoppingList *> *fetched_objects, NSError *error) {
        NSMutableArray<ShoppingList *> *new_lists = [NSMutableArray new];
        for (PFObject *object in fetched_objects)
        {
            ShoppingList *const list_to_add = [ShoppingList _hydrateShoppingListFromPFObject:object];
            [new_lists addObject:list_to_add];
        }
        AppState *myAppState = [AppState sharedManager];
        myAppState.lists = new_lists;
        completion([NSArray arrayWithArray:new_lists],nil);
    }];
}

//makes a list to house a given list object
+ (ShoppingList*)_hydrateShoppingListFromPFObject: (PFObject *)object {
    NSArray<PFObject *> *item_objects = object[@"items"];
    NSMutableArray<Item *> *items = [NSMutableArray new];
    for (PFObject* item_object in item_objects){
        PFQuery *query = [PFQuery queryWithClassName:@"Item"];
        [query getObjectInBackgroundWithId:item_object.objectId block:^(PFObject *full_item_object, NSError *error){
            if(!error) {
                Item *new_item = [Item createItemFromPFObject:full_item_object];
                [items addObject:new_item];
            }
            else {
                NSLog(@"%@",error);
            }
        }];
    }
    ShoppingList *const newList = [[ShoppingList alloc] initWithStore_name:object[@"store_name"] items:[NSArray arrayWithArray:items]];
    newList.listObject = object;
    newList.objectID = object.objectId;
    return newList;
}


@end
