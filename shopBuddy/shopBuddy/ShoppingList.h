/**
 * This file is generated using the remodel generation script.
 * The name of the input file is ShoppingList.value
 */

#import <Foundation/Foundation.h>
@class Item;

@interface ShoppingList : NSObject <NSCopying>

@property (nonatomic, readonly, copy) NSString *store_name;
@property (nonatomic, readonly, copy) NSArray<Item*> *items;

- (instancetype)initWithStore_name:(NSString *)store_name items:(NSArray<Item*> *)items;

@end

