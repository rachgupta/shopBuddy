//
//  ResultCell.h
//  shopBuddy
//
//  Created by Rachna Gupta on 7/15/22.
//

#import <UIKit/UIKit.h>
#import "Item.h"

NS_ASSUME_NONNULL_BEGIN

@interface ResultCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *itemTitle;
@property (weak, nonatomic) IBOutlet UIImageView *itemPhoto;


@end

NS_ASSUME_NONNULL_END
