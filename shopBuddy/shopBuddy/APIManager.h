//
//  APIManager.h
//  shopBuddy
//
//  Created by Rachna Gupta on 7/12/22.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

NS_ASSUME_NONNULL_BEGIN


@interface APIManager : NSObject
@property (strong, nonatomic) AFHTTPSessionManager *manager;

+ (instancetype)shared;


- (void)getItem:(void(^)(NSDictionary *itemDetails, NSError *error))completion;

@end

NS_ASSUME_NONNULL_END
