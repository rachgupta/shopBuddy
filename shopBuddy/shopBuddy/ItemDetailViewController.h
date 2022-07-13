//
//  ItemDetailViewController.h
//  shopBuddy
//
//  Created by Rachna Gupta on 7/11/22.
//

#import <UIKit/UIKit.h>
#import "Item.h"

NS_ASSUME_NONNULL_BEGIN

@interface ItemDetailViewController : UIViewController
@property (strong, nonatomic) NSString *barcode;
@property Item *item;

@end

NS_ASSUME_NONNULL_END
