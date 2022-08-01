//
//  Cart+Persistent.h
//  shopBuddy
//
//  Created by Rachna Gupta on 8/1/22.
//

#import "Cart.h"
#import "Parse/Parse.h"

NS_ASSUME_NONNULL_BEGIN

@interface Cart (Persistent)

@property (nonatomic,copy) PFObject *cartObject;

@end

NS_ASSUME_NONNULL_END
