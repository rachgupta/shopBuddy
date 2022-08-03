//
//  Cart+Persistent.h
//  shopBuddy
//
//  Created by Rachna Gupta on 8/1/22.
//

#import "Cart.h"
#import "Parse/Parse.h"
#import "ShoppingList+Persistent.h"

NS_ASSUME_NONNULL_BEGIN

@interface Cart (Persistent)

@property (nonatomic,copy) PFObject *cartObject;

+ (void) createEmptyCart:(void(^)(Cart *new_cart,NSError *error))completion;

+ (void) addItemToCart:(Cart *)cart withItem:(Item *)item fromList:(ShoppingList *)list withCompletion:(void(^)(Cart* updatedCart, NSError *error))completion;

+ (void) fetchCurrentCart:(void(^)(Cart *cart,NSError *error))completion;

+ (void)updatePrice:(NSNumber *)price forItem:(Item *)item withCart:(Cart *)cart withCompletion:(void(^)(Cart* cart))completion;
@end

NS_ASSUME_NONNULL_END
