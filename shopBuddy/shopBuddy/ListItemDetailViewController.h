//
//  ListItemDetailViewController.h
//  shopBuddy
//
//  Created by Rachna Gupta on 7/27/22.
//

#import <UIKit/UIKit.h>
#import "Item.h"
#import "ShoppingList+Persistent.h"

NS_ASSUME_NONNULL_BEGIN

@interface ListItemDetailViewController : UIViewController
@property Item *item;
@property ShoppingList *list;

@end

NS_ASSUME_NONNULL_END
