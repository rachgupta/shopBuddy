/**
 * This file is generated using the remodel generation script.
 * The name of the input file is Price.value
 */

#import <Foundation/Foundation.h>

@interface Price : NSObject <NSCopying>

@property (nonatomic, readonly, copy) NSString *store;
@property (nonatomic, readonly, copy) NSNumber *price;

- (instancetype)initWithStore:(NSString *)store price:(NSNumber *)price;

@end

