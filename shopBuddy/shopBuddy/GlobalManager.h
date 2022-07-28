//
//  GlobalManager.h
//  shopBuddy
//
//  Created by Rachna Gupta on 7/27/22.
//

#import <Foundation/Foundation.h>
#import "Item.h"

NS_ASSUME_NONNULL_BEGIN

@interface GlobalManager : NSObject

@property (atomic, strong) NSMutableDictionary<NSString *, NSString *> *itemJobIdMap;
@property (atomic, strong) NSMutableArray<NSString *> *outstandingJobs; // Job sync in progress
@property (atomic, strong) NSMutableDictionary<NSString *, NSDictionary *> *completeJobs;

+ (id)sharedManager;

- (void)fetchPricesWithItem:(Item *)item fromStore: (NSString *)store completion:(void(^)(NSDictionary *prices, BOOL success))completion;

@end

NS_ASSUME_NONNULL_END
