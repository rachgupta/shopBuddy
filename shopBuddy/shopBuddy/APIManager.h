//
//  APIManager.h
//  shopBuddy
//
//  Created by Rachna Gupta on 7/12/22.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "Item.h"

NS_ASSUME_NONNULL_BEGIN


@interface APIManager : NSObject

+ (instancetype)shared;

- (void)getItemWithBarcode:(NSString *)barcode completion:(void(^)(Item *item, NSError *error))completion;

- (void)getItemWithSearch:(NSString *)search completion:(void(^)(NSMutableArray<Item*> *items, NSError *error))completion;

@end

NS_ASSUME_NONNULL_END
