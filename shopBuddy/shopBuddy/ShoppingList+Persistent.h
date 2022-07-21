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
- (void) saveList: (ShoppingList *)list;
- (void) addItemToList: (Item *)item withList: (ShoppingList *)list withCompletion: (PFBooleanResultBlock  _Nullable)completion;
@end

NS_ASSUME_NONNULL_END
