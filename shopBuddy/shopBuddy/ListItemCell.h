//
//  ListItemCell.h
//  shopBuddy
//
//  Created by Rachna Gupta on 7/20/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ListItemCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *itemTitle;
@property (weak, nonatomic) IBOutlet UIImageView *itemPhoto;

@end

NS_ASSUME_NONNULL_END
