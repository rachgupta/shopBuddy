/**
 * This file is generated using the remodel generation script.
 * The name of the input file is Item.value
 */

#import <Foundation/Foundation.h>

@interface Item : NSObject <NSCopying>

@property (nonatomic, copy) NSNumber *barcode_number;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSArray<NSString *> *images;
@property (nonatomic, copy) NSString *list;
@property (nonatomic, copy) NSString *brand;
@property (nonatomic, copy) NSString *item_description;

- (instancetype)initWithBarcode_number:(NSNumber *)barcode_number name:(NSString *)name images:(NSArray<NSString *> *)images list:(NSString *)list brand:(NSString *)brand item_description:(NSString *)item_description;
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

