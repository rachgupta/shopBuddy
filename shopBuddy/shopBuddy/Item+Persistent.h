//
//  Item+Persistent.h
//  shopBuddy
//
//  Created by Rachna Gupta on 7/21/22.
//

#import "Item.h"
#import "Parse/Parse.h"
#import "ShoppingList.h"

NS_ASSUME_NONNULL_BEGIN

@interface Item (Persistent)

@property (nonatomic,copy) NSString *objectID;

+ (void) createObject:(PFObject *)object;

+ (Item *) createItemWithDictionary:(NSDictionary *)dictionary;

+ (Item *) hydrateItemFromPFObject: (PFObject *)object;

- (PFObject *) hydratePFObjectFromItemWithListObject: (PFObject *)list;

+ (PFObject *)populateObjectFromPointerObject: (PFObject *)object;

@end

NS_ASSUME_NONNULL_END
