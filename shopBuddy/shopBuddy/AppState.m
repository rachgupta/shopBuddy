//
//  AppState.m
//  shopBuddy
//
//  Created by Rachna Gupta on 8/1/22.
//

#import "AppState.h"
#import "ShoppingList+Persistent.h"

@implementation AppState

+ (id)sharedManager {
    static AppState *sharedAppState = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedAppState = [[self alloc] init];
    });
    return sharedAppState;
}

- (id)init {
    if (self = [super init]) {
        self.lists = [NSArray new];
        self.trips = [NSArray new];
    }
    return self;
}
- (void)addItemToList:(ShoppingList *)list withItem: (Item *)item withCompletion:(void(^)(BOOL succeeded, NSError *error))completion{
    [ShoppingList createFromList:list withItem:item withCompletion:^(ShoppingList* updatedList, NSError *error) {
        if(!error) {
            [ShoppingList fetchLists:^(NSArray<ShoppingList *> *lists, NSError *error) {
                completion(YES,nil);
            }];
        }
        else {
            completion(NO,error);
        }
    }];
}

- (void)updateAppState:(void(^)(BOOL succeeded))completion {
    [ShoppingList fetchLists:^(NSArray<ShoppingList *> *lists, NSError *error) {
        [Cart fetchCurrentCart:^(Cart * _Nonnull cart, NSError * _Nonnull error) {
            [Trip fetchTrips:^(NSArray<Trip *> * _Nonnull trips, NSError * _Nonnull error) {
                completion(YES);
            }];
        }];
    }];
}
@end
