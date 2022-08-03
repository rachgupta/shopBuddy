//
//  CartItemCell.h
//  shopBuddy
//
//  Created by Rachna Gupta on 8/2/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CartItemCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *itemPhoto;
@property (weak, nonatomic) IBOutlet UILabel *itemTitle;
@property (weak, nonatomic) IBOutlet UILabel *itemPrice;

@end

NS_ASSUME_NONNULL_END
