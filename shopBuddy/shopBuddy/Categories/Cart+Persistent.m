//
//  Cart+Persistent.m
//  shopBuddy
//
//  Created by Rachna Gupta on 8/1/22.
//

#import "Cart+Persistent.h"
#import <objc/runtime.h>
#import "Item+Persistent.h"
#import "AppState.h"
@implementation Cart (Persistent)

- (PFObject *)cartObject {
    return objc_getAssociatedObject(self, @selector(cartObject));
}

- (void)setCartObject:(PFObject *)new_cartObject {
    objc_setAssociatedObject(self, @selector(cartObject), new_cartObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (void) fetchCurrentCart:(void(^)(Cart *cart,NSError *error))completion{
    PFQuery *query = [PFQuery queryWithClassName:@"Cart"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray <PFObject *> *fetched_objects, NSError *error) {
        [Cart _hydrateCartFromPFObject:fetched_objects[0] withCompletion:^(Cart *cart) {
            AppState *myAppState = [AppState sharedManager];
            myAppState.cart = cart;
            completion(cart,nil);
        }];
    }];
    
}

//Used to create new carts
+ (void)createEmptyCart:(void(^)(Cart *new_cart,NSError *error))completion{
    NSDictionary *const dict = @{ @"user" : [PFUser currentUser], @"items" : [NSArray new], @"item_prices" : [NSDictionary new], @"item_store" : [NSDictionary new]};
    PFObject *new_object = [PFObject objectWithClassName:@"Cart" dictionary:dict];
    [new_object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        if(succeeded) {
            [Cart _hydrateCartFromPFObject:new_object withCompletion:^(Cart *cart) {
                completion(cart,nil);
            }];
        }
        else {
            completion(nil,error);
        }
    }];
}

+ (void)updatePrice:(NSNumber *)price forItem:(Item *)item withCart:(Cart *)cart withCompletion:(void(^)(Cart* cart))completion{
    NSMutableDictionary *const item_prices = [NSMutableDictionary dictionaryWithDictionary: cart.item_prices];
    item_prices[item.objectID] = price;
    Cart *const newCart = [[Cart alloc] initWithItems:cart.items item_prices:item_prices item_store:cart.item_store];
    newCart.cartObject = cart.cartObject;
    newCart.cartObject[@"item_prices"] = newCart.item_prices;
    newCart.cartObject[@"item_store"] = cart.cartObject[@"item_store"];
    newCart.cartObject[@"items"] = cart.cartObject[@"items"];
    [newCart.cartObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        if(succeeded) {
            completion(newCart);
        }
        else {
            completion(nil);
        }
    }];
}

//makes a cart to house a given cart object
+ (void)_hydrateCartFromPFObject: (PFObject *)object withCompletion:(void(^)(Cart* cart))completion{
    NSArray<PFObject *> *const item_objects = object[@"items"];
    NSDictionary<NSString *, NSNumber *>  *const item_prices = object[@"item_prices"];
    NSDictionary<NSString *, NSString *>  *const item_store = object[@"item_store"];
    NSMutableArray<Item *> *const items = [NSMutableArray new];
    dispatch_group_t group = dispatch_group_create();
    for (PFObject* item_object in item_objects){
        dispatch_group_enter(group);
        PFQuery *const query = [PFQuery queryWithClassName:@"Item"];
        [query getObjectInBackgroundWithId:item_object.objectId block:^(PFObject *full_item_object, NSError *error){
            if(!error) {
                Item *new_item = [Item createItemFromPFObject:full_item_object];
                [items addObject:new_item];
                dispatch_group_leave(group);
            }
        }];
    }
    dispatch_group_notify(group,dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ {
        
        Cart *const newCart = [[Cart alloc] initWithItems:items item_prices:item_prices item_store:item_store];
        newCart.cartObject = object;
        completion(newCart);
    });
}

//add items to cart
+ (void) addItemToCart:(Cart *)cart withItem:(Item *)item fromList:(ShoppingList *)list withCompletion:(void(^)(Cart* updatedCart, NSError *error))completion {
    NSMutableArray *const mutable_items = [NSMutableArray arrayWithArray:cart.items];
    [mutable_items addObject:item];
    NSMutableDictionary *const item_prices = [NSMutableDictionary dictionaryWithDictionary: cart.item_prices];
    NSMutableDictionary *const item_store = [NSMutableDictionary dictionaryWithDictionary: cart.item_store];
    NSNumber *def = [NSNumber numberWithFloat:0.0];
    for (Price *price in item.prices) {
        if([price.store isEqual:list.store_name]) {
            def = price.price;
        }
    }
    item_prices[item.objectID] = def;
    item_store[item.objectID] = list.store_name;
    Cart *const newCart = [[Cart alloc] initWithItems:[mutable_items copy] item_prices:item_prices item_store:item_store];
    newCart.cartObject = cart.cartObject;
    NSMutableArray *previous_items = [NSMutableArray arrayWithArray:newCart.cartObject[@"items"]];
    PFObject *itemObject = [item hydratePFObjectFromItemWithListObject:list.listObject];
    itemObject.objectId = item.objectID;
    [previous_items addObject:itemObject];
    newCart.cartObject[@"items"] = previous_items;
    newCart.cartObject[@"item_prices"] = newCart.item_prices;
    newCart.cartObject[@"item_store"] = newCart.item_store;
    [newCart.cartObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        if(succeeded) {
            completion(newCart, nil);
        }
        else {
            completion(nil, error);
        }
    }];
}
@end
