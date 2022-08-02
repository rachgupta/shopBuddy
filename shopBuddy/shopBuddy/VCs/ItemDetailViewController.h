//
//  ItemDetailViewController.h
//  shopBuddy
//
//  Created by Rachna Gupta on 7/11/22.
//

#import <UIKit/UIKit.h>
#import "Item.h"
#import "ShoppingList.h"
#import "ShoppingListManagerViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ItemDetailViewController : UIViewController
@property (strong, nonatomic) NSString *barcode;
@property Item *item;
@property (strong, nonatomic) NSArray<ShoppingList *> *lists;

@end

NS_ASSUME_NONNULL_END
