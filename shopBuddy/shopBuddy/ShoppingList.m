/**
 * This file is generated using the remodel generation script.
 * The name of the input file is ShoppingList.value
 */

#if  ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

#import "ShoppingList.h"
#import "Item.h"

@implementation ShoppingList

- (instancetype)initWithStore_name:(NSString *)store_name items:(NSArray<Item*> *)items
{
  if ((self = [super init])) {
    _store_name = [store_name copy];
    _items = [items copy];
  }

  return self;
}

- (id)copyWithZone:(NSZone *)zone
{
  return self;
}

- (NSString *)description
{
  return [NSString stringWithFormat:@"%@ - \n\t store_name: %@; \n\t items: %@; \n", [super description], _store_name, _items];
}

- (NSUInteger)hash
{
  NSUInteger subhashes[] = {[_store_name hash], [_items hash]};
  NSUInteger result = subhashes[0];
  for (int ii = 1; ii < 2; ++ii) {
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

- (BOOL)isEqual:(ShoppingList *)object
{
  if (self == object) {
    return YES;
  } else if (self == nil || object == nil || ![object isKindOfClass:[self class]]) {
    return NO;
  }
  return
    (_store_name == object->_store_name ? YES : [_store_name isEqual:object->_store_name]) &&
    (_items == object->_items ? YES : [_items isEqual:object->_items]);
}

@end

