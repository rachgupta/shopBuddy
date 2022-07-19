/**
 * This file is generated using the remodel generation script.
 * The name of the input file is ShoppingList.value
 */

#import <Foundation/Foundation.h>
#import "Parse/Parse.h"
#import "Item.h"

@interface ShoppingList : PFObject <PFSubclassing>

@property (nonatomic) NSString *store_name;
@property (nonatomic) NSMutableArray<Item*>  *items;
@property (nonatomic) PFUser *user;

+ (void) createList:(NSString *)store_name withCompletion: (PFBooleanResultBlock  _Nullable)completion;
- (void) refreshPost;


@end
