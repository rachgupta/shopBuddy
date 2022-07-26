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
@property (nonatomic,copy) PFObject *itemObject;

+ (Item *) createItemWithDictionary:(NSDictionary *)dictionary;

+ (Item *) createItemFromPFObject: (PFObject *)object;

- (PFObject *) hydratePFObjectFromItemWithListObject: (PFObject *)list;

@end

NS_ASSUME_NONNULL_END
