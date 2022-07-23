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

+ (void) createEmptyList:(NSString *)store_name withCompletion:(void(^)(ShoppingList *new_list))completion;

+ (void) addItemToList: (Item *)item withList: (ShoppingList *)list;

- (void) fetchItemsInList: (void(^)(NSArray<Item *> *items, NSError *error))completion;

+ (void) fetchListsByUser: (PFUser *) user withCompletion:(void(^)(NSArray<ShoppingList *> *lists, NSError *error))completion;

@end


NS_ASSUME_NONNULL_END
