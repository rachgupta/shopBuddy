//
//  ShoppingListManagerViewController.h
//  shopBuddy
//
//  Created by Rachna Gupta on 7/18/22.
//

#import <UIKit/UIKit.h>
#import "ShoppingList.h"
#import "Item.h"

NS_ASSUME_NONNULL_BEGIN
@protocol ShoppingListDelegate

- (void)addItemToList:(ShoppingList *)list withItem: (Item *)item withCompletion:(void(^)(BOOL succeeded, NSError *error))completion;

@end


@interface ShoppingListManagerViewController : UIViewController
@end

NS_ASSUME_NONNULL_END
