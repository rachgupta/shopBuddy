/**
 * This file is generated using the remodel generation script.
 * The name of the input file is Trip.value
 */

#import <Foundation/Foundation.h>
#import "Item.h"
@interface Trip : NSObject <NSCopying>

@property (nonatomic, readonly, copy) NSDate *date;
@property (nonatomic, readonly, copy) NSArray<Item*> *items;
@property (nonatomic, readonly, copy) NSNumber *price;
@property (nonatomic, readonly, copy) NSNumber *money_saved;

- (instancetype)initWithDate:(NSDate *)date items:(NSArray<Item*> *)items price:(NSNumber *)price money_saved:(NSNumber *)money_saved;

@end

