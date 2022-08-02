/**
 * This file is generated using the remodel generation script.
 * The name of the input file is Cart.value
 */

#import <Foundation/Foundation.h>
#import "Item.h"

@interface Cart : NSObject <NSCopying>

@property (nonatomic, readonly, copy) NSArray<Item*> *items;

- (instancetype)initWithItems:(NSArray<Item*> *)items;

@end

