/**
 * This file is generated using the remodel generation script.
 * The name of the input file is List.value
 */

#import <Foundation/Foundation.h>
#import "Item.h"

@interface ShoppingList : NSObject <NSCopying>

@property (nonatomic, readonly, copy) NSString *store;
@property (nonatomic, readonly, copy) NSArray<Item*> *items;

- (instancetype)initWithStore:(NSString *)store items:(NSArray<Item*> *)items;

@end

