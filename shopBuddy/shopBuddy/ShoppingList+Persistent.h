//
//  ShoppingList+Persistent.h
//  shopBuddy
//
//  Created by Rachna Gupta on 7/21/22.
//

#import "ShoppingList.h"

NS_ASSUME_NONNULL_BEGIN

@interface ShoppingList (Persistent)

+ (void) createEmptyList:(NSString *)store_name withCompletion: (PFBooleanResultBlock  _Nullable)completion;
- (void) saveList;
- (void) addItemToList: (Item *)item withCompletion: (PFBooleanResultBlock  _Nullable)completion;
- (void) fetchItemsInList: (void(^)(NSArray<Item *> *items, NSError *error))completion;
+ (void) fetchListsByUser: (PFUser *) user withCompletion:(void(^)(NSArray<ShoppingList *> *lists, NSError *error))completion;
@end

NS_ASSUME_NONNULL_END
