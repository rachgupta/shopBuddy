/**
 * This file is generated using the remodel generation script.
 * The name of the input file is Trip.value
 */

#import <Foundation/Foundation.h>

@interface Trip : NSObject <NSCopying>

@property (nonatomic, readonly, copy) NSInteger *trip_id;
@property (nonatomic, readonly, copy) NSDate *date;
@property (nonatomic, readonly, copy) NSString *name;
@property (nonatomic, readonly, copy) NSArray<Item*> *items;
@property (nonatomic, readonly, copy) double *price;
@property (nonatomic, readonly, copy) double *money_saved;

- (instancetype)initWithTrip_id:(NSInteger *)trip_id date:(NSDate *)date name:(NSString *)name items:(NSArray<Item*> *)items price:(double *)price money_saved:(double *)money_saved;

@end

