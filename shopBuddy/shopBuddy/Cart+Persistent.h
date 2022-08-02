//
//  Cart+Persistent.h
//  shopBuddy
//
//  Created by Rachna Gupta on 8/1/22.
//

#import "Cart.h"
#import "Parse/Parse.h"

NS_ASSUME_NONNULL_BEGIN

@interface Cart (Persistent)

@property (nonatomic,copy) PFObject *cartObject;

+ (void) createEmptyCart:(void(^)(Cart *new_cart,NSError *error))completion;

+ (void) addItemToCart:(Cart *)cart withItem:(Item *)item withCompletion:(void(^)(Cart* updatedCart, NSError *error))completion;

@end

NS_ASSUME_NONNULL_END
