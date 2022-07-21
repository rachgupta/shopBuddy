/**
 * This file is generated using the remodel generation script.
 * The name of the input file is ShoppingList.value
 */
#import <Foundation/Foundation.h>
#import "Parse/Parse.h"
#import "Item.h"

@interface ShoppingList : PFObject <PFSubclassing>

@property (nonatomic) NSString *store_name;
@property (nonatomic) PFUser *user;
@property (nonatomic) NSArray<Item*> *items;


@end
