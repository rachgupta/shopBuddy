/**
 * This file is generated using the remodel generation script.
 * The name of the input file is List.value
 */

#if  ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

#import "ShoppingList.h"
#import "Item.h"

@implementation ShoppingList

- (instancetype)initWithStore:(NSString *)store items:(NSArray<Item*> *)items
{
  if ((self = [super init])) {
    _store = [store copy];
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
  return [NSString stringWithFormat:@"%@ - \n\t store: %@; \n\t items: %@; \n", [super description], _store, _items];
}

- (NSUInteger)hash
{
  NSUInteger subhashes[] = {[_store hash], [_items hash]};
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
    (_store == object->_store ? YES : [_store isEqual:object->_store]) &&
    (_items == object->_items ? YES : [_items isEqual:object->_items]);
}

@end

