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

- (NSString *)cartObject {
    return objc_getAssociatedObject(self, @selector(cartObject));
}

- (void)setCartObject:(NSString *)new_cartObject {
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
+ (void) createEmptyCart:(void(^)(Cart *new_cart,NSError *error))completion{
    NSDictionary *const dict = @{ @"user" : [PFUser currentUser], @"items" : [NSArray new] };
    PFObject *new_object = [PFObject objectWithClassName:@"Cart" dictionary:dict];
    [new_object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        if(succeeded) {
            [Cart _hydrateCartFromPFObject:new_object withCompletion:^(Cart *cart) {
                completion(cart,nil);
            }];
        }
        else {
            NSLog(@"Error: %@",error);
            completion(nil,error);
        }
    }];
}

//makes a list to house a given cart object
+ (void)_hydrateCartFromPFObject: (PFObject *)object withCompletion:(void(^)(Cart* cart))completion{
    NSArray<PFObject *> *item_objects = object[@"items"];
    NSMutableArray<Item *> *items = [NSMutableArray new];
    dispatch_group_t group = dispatch_group_create();
    for (PFObject* item_object in item_objects){
        dispatch_group_enter(group);
        NSLog(@"enter");
        PFQuery *query = [PFQuery queryWithClassName:@"Item"];
        [query getObjectInBackgroundWithId:item_object.objectId block:^(PFObject *full_item_object, NSError *error){
            if(!error) {
                Item *new_item = [Item createItemFromPFObject:full_item_object];
                [items addObject:new_item];
                NSLog(@"leave");
                dispatch_group_leave(group);
            }
            else{
                NSLog(@"%@",error);
            }
        }];
    }
    dispatch_group_notify(group,dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ {
        Cart *const newCart = [[Cart alloc] initWithItems:items];
        newCart.cartObject = object;
        completion(newCart);
    });
}

//add items to cart
+ (void) addItemToCart:(Cart *)cart withItem:(Item *)item withCompletion:(void(^)(Cart* updatedCart, NSError *error))completion {
    NSMutableArray *const mutable_items = [NSMutableArray arrayWithArray:cart.items];
    [mutable_items addObject:item];
    Cart *const newCart = [[Cart alloc] initWithItems:[mutable_items copy]];
    newCart.cartObject = cart.cartObject;
    completion(newCart,nil);
    /*
    NSMutableArray *previous_items = [NSMutableArray arrayWithArray:newCart.cartObject[@"items"]];
    [previous_items addObject:item.itemObject];
    newCart.cartObject[@"items"] = [NSArray arrayWithArray:previous_items];
    [newCart.cartObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        if(succeeded) {
            completion(newCart, nil);
        }
        else {
            completion(nil, error);
        }
    }];
    */
}
@end
