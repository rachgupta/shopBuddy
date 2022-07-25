//
//  ResultCell.h
//  shopBuddy
//
//  Created by Rachna Gupta on 7/15/22.
//

#import <UIKit/UIKit.h>
#import "Item.h"

NS_ASSUME_NONNULL_BEGIN

@interface SearchResultItemCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *itemPhoto;
@property (weak, nonatomic) IBOutlet UILabel *itemTitle;


@end

NS_ASSUME_NONNULL_END
