//
//  AppState.h
//  shopBuddy
//
//  Created by Rachna Gupta on 8/1/22.
//

#import <Foundation/Foundation.h>
#import "ShoppingList+Persistent.h"
#import "Cart+Persistent.h"

NS_ASSUME_NONNULL_BEGIN

@interface AppState : NSObject

@property (strong, nonatomic) NSArray<ShoppingList *> *lists;
@property (strong, nonatomic) Cart *cart;

+ (id)sharedManager;
- (void)addItemToList:(ShoppingList *)list withItem: (Item *)item withCompletion:(void(^)(BOOL succeeded, NSError *error))completion;

@end

NS_ASSUME_NONNULL_END
