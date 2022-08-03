/**
 * This file is generated using the remodel generation script.
 * The name of the input file is Item.value
 */

#if  ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

#import "Item.h"

@implementation Item

- (instancetype)initWithBarcode_number:(NSNumber *)barcode_number name:(NSString *)name images:(NSArray<NSString *> *)images brand:(NSString *)brand item_description:(NSString *)item_description
{
  if ((self = [super init])) {
    _barcode_number = [barcode_number copy];
    _name = [name copy];
    _images = [images copy];
    _brand = [brand copy];
    _item_description = [item_description copy];
  }

  return self;
}

- (id)copyWithZone:(NSZone *)zone
{
  return self;
}

- (NSString *)description
{
  return [NSString stringWithFormat:@"%@ - \n\t barcode_number: %@; \n\t name: %@; \n\t images: %@; \n\t brand: %@; \n\t item_description: %@; \n", [super description], _barcode_number, _name, _images, _brand, _item_description];
}

- (NSUInteger)hash
{
  NSUInteger subhashes[] = {[_barcode_number hash], [_name hash], [_images hash], [_brand hash], [_item_description hash]};
  NSUInteger result = subhashes[0];
  for (int ii = 1; ii < 5; ++ii) {
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

- (BOOL)isEqual:(Item *)object
{
  if (self == object) {
    return YES;
  } else if (self == nil || object == nil || ![object isKindOfClass:[self class]]) {
    return NO;
  }
  return
    (_barcode_number == object->_barcode_number ? YES : [_barcode_number isEqual:object->_barcode_number]) &&
    (_name == object->_name ? YES : [_name isEqual:object->_name]) &&
    (_images == object->_images ? YES : [_images isEqual:object->_images]) &&
    (_brand == object->_brand ? YES : [_brand isEqual:object->_brand]) &&
    (_item_description == object->_item_description ? YES : [_item_description isEqual:object->_item_description]);
}

@end

