/**
 * This file is generated using the remodel generation script.
 * The name of the input file is Item.value
 */

#import <Foundation/Foundation.h>
#import "Parse/Parse.h"
#import "ShoppingList.h"

@interface Item : PFObject <PFSubclassing>

@property (nonatomic) NSNumber *barcode_number;
@property (nonatomic) NSString *name;
@property (nonatomic) NSArray<NSString *> *images;
@property (nonatomic) ShoppingList *list;
@property (nonatomic) NSString *brand;
@property (nonatomic) NSString *item_description;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

