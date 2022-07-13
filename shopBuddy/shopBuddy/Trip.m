/**
 * This file is generated using the remodel generation script.
 * The name of the input file is Trip.value
 */

#if  ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

#import "Trip.h"
#import "Item.h"

@implementation Trip

- (instancetype)initWithTrip_id:(NSNumber *)trip_id date:(NSDate *)date name:(NSArray<NSString*> *)store_names items:(NSArray<Item*> *)items price:(NSNumber *)price money_saved:(NSNumber *)money_saved
{
  if ((self = [super init])) {
    _trip_id = [trip_id copy];
    _date = [date copy];
    _store_names = [store_names copy];
    _items = [items copy];
    _price = [price copy];
    _money_saved = [money_saved copy];
  }

  return self;
}

- (id)copyWithZone:(NSZone *)zone
{
  return self;
}


- (BOOL)isEqual:(Trip *)object
{
  if (self == object) {
    return YES;
  } else if (self == nil || object == nil || ![object isKindOfClass:[self class]]) {
    return NO;
  }
  return
    (_trip_id == object->_trip_id ? YES : [_trip_id isEqual:object->_trip_id]) &&
    (_date == object->_date ? YES : [_date isEqual:object->_date]) &&
    (_store_names == object->_store_names ? YES : [_store_names isEqual:object->_store_names]) &&
    (_items == object->_items ? YES : [_items isEqual:object->_items]) &&
    (_price == object->_price ? YES : [_price isEqual:object->_price]) &&
    (_money_saved == object->_money_saved ? YES : [_money_saved isEqual:object->_money_saved]);
}

@end

