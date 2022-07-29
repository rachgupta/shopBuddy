//
//  ListItemDetailViewController.m
//  shopBuddy
//
//  Created by Rachna Gupta on 7/27/22.
//

#import "ListItemDetailViewController.h"
#import "UIImageView+AFNetworking.h"

@interface ListItemDetailViewController () {
    
    __weak IBOutlet UIImageView *itemImage;
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UILabel *brandLabel;
    __weak IBOutlet UITextView *descriptionView;
    __weak IBOutlet UILabel *listLabel;
    
}

@end

@implementation ListItemDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _populateView];
    // Do any additional setup after loading the view.
}

- (void)_populateView {
    //TODO: add Show More button and shortened description
    titleLabel.text = self.item.name;
    brandLabel.text = self.item.brand;
    descriptionView.text = self.item.item_description;
    NSString *const URLString = self.item.images[0];
    NSURL *const url = [NSURL URLWithString:URLString];
    [itemImage setImageWithURL:url];
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
