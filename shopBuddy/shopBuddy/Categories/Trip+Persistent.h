//
//  Trip+Persistent.h
//  shopBuddy
//
//  Created by Rachna Gupta on 8/3/22.
//

#import "Trip.h"
#import "Parse/Parse.h"
#import "Cart+Persistent.h"

NS_ASSUME_NONNULL_BEGIN

@interface Trip (Persistent)

@property (nonatomic,copy) PFObject *tripObject;
@property (nonatomic,copy) NSNumber *totalCouldHaveSaved;

+ (void)fetchTrips:(void(^)(NSArray<Trip *> *trips, NSError *error))completion;

+ (void)createTripFromCart:(Cart *)cart withCompletion:(void(^)(Trip *new_trip,NSError *error))completion;

@end

NS_ASSUME_NONNULL_END
