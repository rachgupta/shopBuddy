/**
 * This file is generated using the remodel generation script.
 * The name of the input file is Trip.value
 */

#import <Foundation/Foundation.h>
#import "Item+Persistent.h"

@interface Trip : NSObject <NSCopying>

@property (nonatomic, readonly, copy) NSArray<Item*> *items;
@property (nonatomic, readonly, copy) NSDictionary<NSString *,NSNumber *> *item_prices;
@property (nonatomic, readonly, copy) NSDictionary<NSString *,NSString *> *item_store;
@property (nonatomic, readonly, copy) NSDate *purchase_date;

- (instancetype)initWithItems:(NSArray<Item*> *)items item_prices:(NSDictionary<NSString *,NSNumber *> *)item_prices item_store:(NSDictionary<NSString *,NSString *> *)item_store purchase_date:(NSDate *)purchase_date;

@end

