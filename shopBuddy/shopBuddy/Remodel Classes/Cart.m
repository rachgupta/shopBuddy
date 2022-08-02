/**
 * This file is generated using the remodel generation script.
 * The name of the input file is Cart.value
 */

#if  ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

#import "Cart.h"
#import "Item.h"

@implementation Cart

- (instancetype)initWithItems:(NSArray<Item*> *)items item_prices:(NSDictionary<NSString *,NSNumber *> *)item_prices item_store:(NSDictionary<NSString *,NSString *> *)item_store
{
  if ((self = [super init])) {
    _items = [items copy];
    _item_prices = [item_prices copy];
    _item_store = [item_store copy];
  }

  return self;
}

- (id)copyWithZone:(NSZone *)zone
{
  return self;
}

- (NSString *)description
{
  return [NSString stringWithFormat:@"%@ - \n\t items: %@; \n\t item_prices: %@; \n\t item_store: %@; \n", [super description], _items, _item_prices, _item_store];
}

- (NSUInteger)hash
{
  NSUInteger subhashes[] = {[_items hash], [_item_prices hash], [_item_store hash]};
  NSUInteger result = subhashes[0];
  for (int ii = 1; ii < 3; ++ii) {
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

- (BOOL)isEqual:(Cart *)object
{
  if (self == object) {
    return YES;
  } else if (self == nil || object == nil || ![object isKindOfClass:[self class]]) {
    return NO;
  }
  return
    (_items == object->_items ? YES : [_items isEqual:object->_items]) &&
    (_item_prices == object->_item_prices ? YES : [_item_prices isEqual:object->_item_prices]) &&
    (_item_store == object->_item_store ? YES : [_item_store isEqual:object->_item_store]);
}

@end

