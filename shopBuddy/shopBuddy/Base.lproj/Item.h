/**
 * This file is generated using the remodel generation script.
 * The name of the input file is Item.value
 */

#import <Foundation/Foundation.h>

@interface Item : NSObject <NSCopying>

@property (nonatomic, readonly, copy) NSNumber *barcode_number;
@property (nonatomic, readonly, copy) NSString *name;
@property (nonatomic, readonly, copy) NSArray<NSString *> *images;
@property (nonatomic, readonly, copy) NSString *brand;
@property (nonatomic, readonly, copy) NSString *item_description;

- (instancetype)initWithBarcode_number:(NSNumber *)barcode_number name:(NSString *)name images:(NSArray<NSString *> *)images brand:(NSString *)brand item_description:(NSString *)item_description;

@end

