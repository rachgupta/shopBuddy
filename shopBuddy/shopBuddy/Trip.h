/**
 * This file is generated using the remodel generation script.
 * The name of the input file is Trip.value
 */

#import <Foundation/Foundation.h>
#import "Item.h"

@interface Trip : NSObject <NSCopying>

@property (nonatomic) NSNumber *trip_id;
@property (nonatomic) NSDate *date;
@property (nonatomic) NSArray<NSString*> *store_names;
@property (nonatomic) NSArray<Item*> *items;
@property (nonatomic) NSNumber *price;
@property (nonatomic) NSNumber *money_saved;

- (instancetype)initWithTrip_id:(NSNumber *)trip_id date:(NSDate *)date name:(NSArray<NSString*> *)store_names items:(NSArray<Item*> *)items price:(NSNumber *)price money_saved:(NSNumber *)money_saved;

@end

