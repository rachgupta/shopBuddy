//
//  ItemDetailViewController.m
//  shopBuddy
//
//  Created by Rachna Gupta on 7/11/22.
//

#import "ItemDetailViewController.h"
#import "Item.h"
#import "UIImageView+AFNetworking.h"
#import "APIManager.h"

@interface ItemDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *brandLabel;
@property (weak, nonatomic) IBOutlet UIImageView *itemImage;
@property (weak, nonatomic) IBOutlet UITextView *descriptionView;

@end

@implementation ItemDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.descriptionView.scrollEnabled=YES;
    if(self.hasItemPopulated==YES)
    {
        [self populateView];
    } else {
        [self callAPI];
    }
}

- (void)callAPI {
    [[APIManager shared] getItemWithBarcode:self.barcode completion:^(Item *item, NSError *error) {
        if (item) {
            self.item = item;
            [self populateView];
        }
        else {
            //TODO: Failure logic
        }
    }];
}

- (void)populateView {
    //TODO: add Show More button and shortened description
    self.titleLabel.text = self.item.name;
    self.brandLabel.text = self.item.brand;
    self.descriptionView.text = self.item.item_description;
    NSString *URLString = self.item.images[0];
    NSURL *url = [NSURL URLWithString:URLString];
    [self.itemImage setImageWithURL:url];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
