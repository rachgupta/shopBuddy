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

@implementation Item (Persistent)



- (NSString *)objectID {
    return objc_getAssociatedObject(self, @selector(objectID));
}

- (void)setObjectID:(NSString *)new_objectID {
    objc_setAssociatedObject(self, @selector(objectID), new_objectID, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary *)prices {
    return objc_getAssociatedObject(self, @selector(prices));
}

- (void)setPrices:(NSDictionary *)new_prices {
    objc_setAssociatedObject(self, @selector(prices), new_prices, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)itemObject {
    return objc_getAssociatedObject(self, @selector(itemObject));
}

- (void)setItemObject:(PFObject *)new_itemObject {
    objc_setAssociatedObject(self, @selector(itemObject), new_itemObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void) _syncPrices {
    //TODO: prices
}

//creates an item from dictionary from api
+ (Item *) createItemWithDictionary:(NSDictionary *)dictionary {
    Item *const new_item = [[Item alloc] initWithBarcode_number:dictionary[@"barcode_number"] name:dictionary[@"title"] images:dictionary[@"images"] brand:dictionary[@"brand"] item_description:dictionary[@"description"]];
    return new_item;
}

//creates a new object from the item in a given list
- (PFObject *) hydratePFObjectFromItemWithListObject: (PFObject *)list {
    NSDictionary *dict = @{ @"name" : self.name, @"barcode_number" : self.barcode_number, @"images" : self.images, @"brand" : self.brand, @"item_description" : self.item_description, @"list" : list};
    PFObject *new_object = [PFObject objectWithClassName:@"Item" dictionary:dict];
    self.itemObject = new_object;
    return [PFObject objectWithClassName:@"Item" dictionary:dict];
}

//creates an item to house the PFObject
+ (Item *) createItemFromPFObject: (PFObject *)object {
    Item *const new_item = [[Item alloc] initWithBarcode_number:object[@"barcode_number"] name:object[@"name"] images:object[@"images"] brand:object[@"brand"] item_description:object[@"item_description"]];
    new_item.objectID = object.objectId;
    new_item.itemObject = object;
    return new_item;
}


@end
