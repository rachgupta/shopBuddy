//
//  ShoppingList+Persistent.h
//  shopBuddy
//
//  Created by Rachna Gupta on 7/21/22.
//

#import "ShoppingList.h"
#import "Parse/Parse.h"

NS_ASSUME_NONNULL_BEGIN

@interface ShoppingList (Persistent)

@property (nonatomic,copy) NSString *objectID;
@property (nonatomic,copy) PFObject *listObject;

+ (void) createEmptyList:(NSString *)store_name withCompletion:(void(^)(ShoppingList *new_list, NSError *error))completion;

+ (void) createFromList:(ShoppingList *)list withItem:(Item *)item withCompletion:(void(^)(ShoppingList* updatedList, NSError *error))completion;

- (void) fetchItemsInList: (void(^)(NSArray<Item *> *items, NSError *error))completion;

+ (void) fetchListsByUser: (PFUser *) user withCompletion:(void(^)(NSArray<ShoppingList *> *lists, NSError *error))completion;

+ (void) removeItemFromList: (ShoppingList *)list withItem: (Item *)item withCompletion:(void(^)(ShoppingList *new_list,NSError *error))completion;

- (void) getItemsFromList:(void(^)(NSArray<Item *> *items, NSError *error))completion;

+ (void) addExistingItem:(Item *)item toList:(ShoppingList *)list withCompletion:(void(^)(Item *item, NSError *error))completion;

@end


NS_ASSUME_NONNULL_END
