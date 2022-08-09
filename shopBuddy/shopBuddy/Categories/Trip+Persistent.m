//
//  Trip+Persistent.m
//  shopBuddy
//
//  Created by Rachna Gupta on 8/3/22.
//

#import "Trip+Persistent.h"
#import <objc/runtime.h>
#import "AppState.h"
#import "Item+Persistent.h"
#import "Cart+Persistent.h"


@implementation Trip (Persistent)

- (PFObject *)tripObject {
    return objc_getAssociatedObject(self, @selector(tripObject));
}

- (void)setTripObject:(PFObject *)new_tripObject {
    objc_setAssociatedObject(self, @selector(tripObject), new_tripObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (PFObject *)totalCouldHaveSaved {
    return objc_getAssociatedObject(self, @selector(totalCouldHaveSaved));
}

- (void)setTotalCouldHaveSaved:(PFObject *)new_totalCouldHaveSaved {
    objc_setAssociatedObject(self, @selector(totalCouldHaveSaved), new_totalCouldHaveSaved, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

//gets all trips by current user
+ (void)fetchTrips:(void(^)(NSArray<Trip *> *trips, NSError *error))completion {
    PFQuery *const query = [PFQuery queryWithClassName:@"Trip"];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    dispatch_group_t tripFetchGroup = dispatch_group_create();
    [query findObjectsInBackgroundWithBlock:^(NSArray <PFObject *> *fetched_objects, NSError *error) {
        NSMutableArray<Trip *> *const new_trips = [NSMutableArray new];
        for (PFObject *object in fetched_objects)
        {
            dispatch_group_enter(tripFetchGroup);
            [Trip _hydrateTripFromPFObject:object withCompletion:^(Trip *trip, NSError *error) {
                if(!error) {
                    [new_trips addObject:trip];
                    dispatch_group_leave(tripFetchGroup);
                }
                else {
                    completion(nil,error);
                    dispatch_group_leave(tripFetchGroup);
                }
            }];
        }
        dispatch_group_notify(tripFetchGroup,dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ {
            AppState *myAppState = [AppState sharedManager];
            myAppState.trips = new_trips;
            completion([NSArray arrayWithArray:new_trips],nil);
        });
    }];
}

- (NSNumber *)_calculateTotalCouldHaveSaved {
    double total = 0;
    for (Item *item in self.items) {
        NSArray<Price *> *prices = item.prices;
        if(prices.count>0) {
            double lowest_price = [prices[0].price doubleValue];
            for (Price *price in prices) {
                if([price.price doubleValue]<lowest_price){
                    lowest_price = [price.price doubleValue];
                }
            }
            double difference = [self.item_prices[item.objectID] doubleValue] - lowest_price;
            if(difference>0) {
                total = total + difference;
            }
        }
    }
    return [NSNumber numberWithDouble:total];
}

+ (void)_hydrateTripFromPFObject: (PFObject *)object withCompletion:(void(^)(Trip * trip, NSError *error))completion {
    NSArray<PFObject *> *const item_objects = object[@"items"];
    NSDictionary<NSString *, NSNumber *>  *const item_prices = object[@"item_prices"];
    NSDictionary<NSString *, NSString *>  *const item_store = object[@"item_store"];
    NSDate *const purchase = object[@"purchase_date"];
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
        
        Trip *const newTrip = [[Trip alloc] initWithItems:items item_prices:item_prices item_store:item_store purchase_date:purchase];
        newTrip.tripObject = object;
        newTrip.totalCouldHaveSaved = [newTrip _calculateTotalCouldHaveSaved];
        completion(newTrip, nil);
    });
}

//Used to create new trips
+ (void)createTripFromCart:(Cart *)cart withCompletion:(void(^)(Trip *new_trip,NSError *error))completion{
    NSMutableArray<PFObject *> *const item_objects = [NSMutableArray new];
    for (Item *item in cart.items) {
        [item_objects addObject:item.itemObject];
    }
    NSDictionary *const dict = @{ @"user" : [PFUser currentUser], @"items" : [NSMutableArray arrayWithArray:item_objects], @"item_prices" : cart.item_prices, @"item_store" : cart.item_store, @"purchase_date" : [NSDate now]};
    PFObject *new_object = [PFObject objectWithClassName:@"Trip" dictionary:dict];
    [new_object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        if(succeeded) {
            [Trip _hydrateTripFromPFObject:new_object withCompletion:^(Trip *trip, NSError *error) {
                completion(trip,nil);
            }];
        }
        else {
            completion(nil,error);
        }
    }];
}

@end
