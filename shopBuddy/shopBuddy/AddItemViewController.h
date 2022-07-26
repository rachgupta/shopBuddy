//
//  AddItemViewController.h
//  shopBuddy
//
//  Created by Rachna Gupta on 7/12/22.
//

#import <UIKit/UIKit.h>
#import "ShoppingList.h"
#import "ShoppingListManagerViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface AddItemViewController : UIViewController
@property (strong, nonatomic) NSArray<ShoppingList *> *lists;
@property (nonatomic, weak) id<ShoppingListDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
