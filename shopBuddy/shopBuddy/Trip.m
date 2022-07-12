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

- (instancetype)initWithTrip_id:(NSNumber *)trip_id date:(NSDate *)date name:(NSString *)name items:(NSArray<Item*> *)items price:(NSNumber *)price money_saved:(NSNumber *)money_saved
{
  if ((self = [super init])) {
    _trip_id = [trip_id copy];
    _date = [date copy];
    _name = [name copy];
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

- (NSString *)description
{
  return [NSString stringWithFormat:@"%@ - \n\t trip_id: %@; \n\t date: %@; \n\t name: %@; \n\t items: %@; \n\t price: %@; \n\t money_saved: %@; \n", [super description], _trip_id, _date, _name, _items, _price, _money_saved];
}

- (NSUInteger)hash
{
  NSUInteger subhashes[] = {[_trip_id hash], [_date hash], [_name hash], [_items hash], [_price hash], [_money_saved hash]};
  NSUInteger result = subhashes[0];
  for (int ii = 1; ii < 6; ++ii) {
    unsigned long long base = (((unsigned long long)result) << 32 | subhashes[ii]);
    base = (~base) + (base << 18);
    base ^= (base >> 31);
    base *=  21;
    base ^= (base >> 11);
    base += (base << 6);
    base ^= (base >> 22);
    result = base;
  }
  return result;
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
    (_name == object->_name ? YES : [_name isEqual:object->_name]) &&
    (_items == object->_items ? YES : [_items isEqual:object->_items]) &&
    (_price == object->_price ? YES : [_price isEqual:object->_price]) &&
    (_money_saved == object->_money_saved ? YES : [_money_saved isEqual:object->_money_saved]);
}

@end

