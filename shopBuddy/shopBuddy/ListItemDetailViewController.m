//
//  ListItemDetailViewController.m
//  shopBuddy
//
//  Created by Rachna Gupta on 7/27/22.
//

#import "ListItemDetailViewController.h"
#import "UIImageView+AFNetworking.h"
#import "Price.h"
#import "Item+Persistent.h"
#import "PriceCell.h"
@interface ListItemDetailViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
{
    
    __weak IBOutlet UIImageView *itemImage;
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UILabel *brandLabel;
    __weak IBOutlet UITextView *descriptionView;
    __weak IBOutlet UILabel *listLabel;
    __weak IBOutlet UICollectionView *collectionView;
    __weak IBOutlet UIActivityIndicatorView *activityIndicator;
    
    
}

@end

@implementation ListItemDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _populateView];
    descriptionView.scrollEnabled=YES;
    collectionView.delegate = self;
    collectionView.dataSource = self;
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
    listLabel.text = [NSString stringWithFormat:@"In %@ List",self.list.store_name];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.item.prices.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PriceCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PriceCell" forIndexPath:indexPath];
    Price *const price = self.item.prices[indexPath.item];
    cell.storeLabel.text = price.store;
    cell.priceLabel.text = [price.price stringValue];
    
    return cell;
}
//TODO: Add prices

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
