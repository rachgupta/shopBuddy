//
//  Item+Persistent.m
//  shopBuddy
//
//  Created by Rachna Gupta on 7/21/22.
//

#import "Item+Persistent.h"
#import "Parse/Parse.h"
#import <objc/runtime.h>
#import "ShoppingList.h"
#import "Price.h"

@interface Item (Persistent)
@property (nonatomic,copy) PFObject *itemObject;
@end
@implementation Item (Persistent)

- (NSString *)objectID {
    return objc_getAssociatedObject(self, @selector(objectID));
}

- (void)setObjectID:(NSString *)new_objectID {
    objc_setAssociatedObject(self, @selector(objectID), new_objectID, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDate *)lastSynced {
    return objc_getAssociatedObject(self, @selector(lastSynced));
}

- (void)setLastSynced:(NSDate *)new_lastSynced {
    objc_setAssociatedObject(self, @selector(lastSynced), new_lastSynced, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray<Price *> *)prices {
    return objc_getAssociatedObject(self, @selector(prices));
}

- (void)setPrices:(NSArray<Price *> *)new_prices {
    objc_setAssociatedObject(self, @selector(prices), new_prices, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)itemObject {
    return objc_getAssociatedObject(self, @selector(itemObject));
}

- (void)setItemObject:(PFObject *)new_itemObject {
    objc_setAssociatedObject(self, @selector(itemObject), new_itemObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void) syncPrices: (NSMutableArray<Price *> *)prices {
    self.prices = prices;
    self.lastSynced = [NSDate now];
    if(self.itemObject) {
        [self _updateSavedItemWithPrices:self.itemObject];
    }
}

- (void) _updateSavedItemWithPrices:(PFObject *)item {
    NSMutableDictionary *priceDict = [NSMutableDictionary new];
    for (Price *price in self.prices) {
        priceDict[price.store] = price.price;
    }
    self.itemObject[@"prices"] = priceDict;
    [self.itemObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){}];
}

//creates an item from dictionary from api
+ (Item *) createItemWithDictionary:(NSDictionary *)dictionary {
    Item *const new_item = [[Item alloc] initWithBarcode_number:dictionary[@"barcode_number"] name:dictionary[@"title"] images:dictionary[@"images"] brand:dictionary[@"brand"] item_description:dictionary[@"description"]];
    return new_item;
}

//creates a new object from the item in a given list
- (PFObject *) hydratePFObjectFromItemWithListObject: (PFObject *)list {
    NSMutableDictionary *const priceDict = [NSMutableDictionary new];
    for (Price *price in self.prices){
        priceDict[price.store] = price.price;
    }
    NSDictionary *const dict = @{ @"name" : self.name, @"barcode_number" : self.barcode_number, @"images" : self.images, @"brand" : self.brand, @"item_description" : self.item_description, @"list" : list, @"prices": priceDict};
    PFObject *const new_object = [PFObject objectWithClassName:@"Item" dictionary:dict];
    NSLog(@"%@",dict);
    NSLog(@"%@",new_object);
    self.itemObject = new_object;
    return [PFObject objectWithClassName:@"Item" dictionary:dict];
}

//creates an item to house the PFObject
+ (Item *) createItemFromPFObject: (PFObject *)object {
    Item *const new_item = [[Item alloc] initWithBarcode_number:object[@"barcode_number"] name:object[@"name"] images:object[@"images"] brand:object[@"brand"] item_description:object[@"item_description"]];
    new_item.objectID = object.objectId;
    new_item.itemObject = object;
    NSMutableArray *prices = [NSMutableArray new];
    NSMutableDictionary *givenPrices = object[@"prices"];
    for (NSString *store in [givenPrices allKeys]) {
        [prices addObject:[[Price alloc] initWithStore:store price:givenPrices[store]]];
    }
    new_item.prices = [NSArray arrayWithArray:prices];
    return new_item;
}

@end
