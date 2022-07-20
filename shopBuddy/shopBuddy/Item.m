/**
 * This file is generated using the remodel generation script.
 * The name of the input file is Item.value
 */

#if  ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

#import "Item.h"

@implementation Item
@dynamic barcode_number;
@dynamic name;
@dynamic images;
@dynamic list;
@dynamic brand;
@dynamic item_description;

+ (nonnull NSString *)parseClassName {
    return @"Item";
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.barcode_number = dictionary[@"barcode_number"];
        self.name = dictionary[@"title"];
        self.images = dictionary[@"images"];
        self.brand = dictionary[@"brand"];
        self.item_description = dictionary[@"description"];
    }
    return self;
}


@end

