/**
 * This file is generated using the remodel generation script.
 * The name of the input file is Cart.value
 */

#import <Foundation/Foundation.h>
#import "Item.h"

@interface Cart : NSObject <NSCopying>

@property (nonatomic, readonly, copy) NSArray<Item*> *items;
@property (nonatomic, readonly, copy) NSDictionary<NSString *,NSNumber *> *item_prices;
@property (nonatomic, readonly, copy) NSDictionary<NSString *,NSString *> *item_store;

- (instancetype)initWithItems:(NSArray<Item*> *)items item_prices:(NSDictionary<NSString *,NSNumber *> *)item_prices item_store:(NSDictionary<NSString *,NSString *> *)item_store;

@end

