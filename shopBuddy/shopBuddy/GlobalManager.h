//
//  GlobalManager.h
//  shopBuddy
//
//  Created by Rachna Gupta on 7/27/22.
//

#import <Foundation/Foundation.h>
#import "Item.h"
#import "Price.h"

NS_ASSUME_NONNULL_BEGIN

@interface GlobalManager : NSObject


+ (id)sharedManager;

- (void)fetchPricesWithItem:(Item *)item fromStore: (NSString *)store completion:(void(^)(NSArray<Price *> *prices, BOOL success))completion;

@end

NS_ASSUME_NONNULL_END
