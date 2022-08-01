//
//  Cart+Persistent.m
//  shopBuddy
//
//  Created by Rachna Gupta on 8/1/22.
//

#import "Cart+Persistent.h"
#import <objc/runtime.h>
#import "Item+Persistent.h"
@implementation Cart (Persistent)

- (NSString *)cartObject {
    return objc_getAssociatedObject(self, @selector(cartObject));
}

- (void)setCartObject:(NSString *)new_cartObject {
    objc_setAssociatedObject(self, @selector(cartObject), new_cartObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

//Used to create new carts
+ (void) createEmptyCart:(void(^)(Cart *new_cart,NSError *error))completion{
    NSDictionary *const dict = @{ @"user" : [PFUser currentUser], @"items" : [NSArray new] };
    PFObject *new_object = [PFObject objectWithClassName:@"Cart" dictionary:dict];
    [new_object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        if(succeeded) {
            Cart *const newCart = [Cart _hydrateCartFromPFObject:new_object];
            completion(newCart,nil);
        }
        else {
            NSLog(@"Error: %@",error);
            completion(nil,error);
        }
    }];
}

//makes a list to house a given cart object
+ (Cart*)_hydrateCartFromPFObject: (PFObject *)object {
    NSArray<PFObject *> *item_objects = object[@"items"];
    NSMutableArray<Item *> *items = [NSMutableArray new];
    for (PFObject* item_object in item_objects){
        PFQuery *query = [PFQuery queryWithClassName:@"Item"];
        [query getObjectInBackgroundWithId:item_object.objectId block:^(PFObject *full_item_object, NSError *error){
            if(!error) {
                Item *new_item = [Item createItemFromPFObject:full_item_object];
                [items addObject:new_item];
            }
        }];
    }
    Cart *const newCart = [[Cart alloc] initWithItems:items];
    newCart.cartObject = object;
    return newCart;
}

//add items to cart
+ (void) addItemToCart:(Cart *)cart withItem:(Item *)item withCompletion:(void(^)(Cart* updatedCart, NSError *error))completion {
    NSMutableArray *const mutable_items = [NSMutableArray arrayWithArray:cart.items];
    [mutable_items addObject:item];
    Cart *const newCart = [[Cart alloc] initWithItems:[mutable_items copy]];
    newCart.cartObject = cart.cartObject;
    completion(newCart,nil);
    //TODO: add functionality
}
@end
