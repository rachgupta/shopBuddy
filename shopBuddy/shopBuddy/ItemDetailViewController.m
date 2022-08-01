//
//  ItemDetailViewController.m
//  shopBuddy
//
//  Created by Rachna Gupta on 7/11/22.
//

#import "ItemDetailViewController.h"
#import "Item.h"
#import "UIImageView+AFNetworking.h"
#import "BarcodeAPIManager.h"
#import "ShoppingList.h"
#import "ShoppingList+Persistent.h"
#import "Parse/Parse.h"
#import "GlobalManager.h"
#import "Item+Persistent.h"
#import "Price.h"
#import "PriceCell.h"
#import "AppState.h"

@interface ItemDetailViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
{
    __weak IBOutlet UITextView *descriptionView;
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UILabel *brandLabel;
    __weak IBOutlet UIImageView *itemImage;
    __weak IBOutlet UIButton *addItemToListButton;
    __weak IBOutlet UICollectionView *collectionView;
    __weak IBOutlet UIActivityIndicatorView *activityIndicator;
    
}

@end

@implementation ItemDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    descriptionView.scrollEnabled=YES;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    AppState *myAppState = [AppState sharedManager];
    self.lists = myAppState.lists;
    [self _makeMenu];
    GlobalManager *myManager = [GlobalManager sharedManager];
    __weak __typeof__(self) weakSelf = self;
    if (self.item != nil) {
        [self _populateView];
        [self _callPricesAPI:myManager];
    } else {
        [self _callBarcodeAPI:^(BOOL success){
            [weakSelf _callPricesAPI:myManager];
        }];
    }
}

- (void)_callBarcodeAPI:(void(^)(BOOL success))completion{
    __weak __typeof__(self) weakSelf = self;
    [[BarcodeAPIManager shared] getItemWithBarcode:self.barcode completion:^(Item *item, NSError *error) {
        if (item) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if(strongSelf)
            {
                strongSelf->_item = item;
                [weakSelf _populateView];
                completion(YES);
            }
        } else {
            //TODO: Failure logic
        }
    }];
}

- (void) _callPricesAPI: (GlobalManager *)manager{
    __weak __typeof__(self) weakSelf = self;
    [activityIndicator startAnimating];
    [manager fetchPricesWithItem:self.item fromStore:@"google_shopping" completion:^(NSArray<Price *> * _Nonnull prices, BOOL success) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if(strongSelf) {
            [strongSelf.item syncPrices:prices];
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf->activityIndicator stopAnimating];
                [strongSelf->collectionView reloadData];
                
            });
        }
    }];
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

- (void) _makeMenu {
    NSMutableArray* actions = [[NSMutableArray alloc] init];
    for (ShoppingList *list in self.lists) {
        NSString *const actionTitle = [NSString stringWithFormat:@"Add Item to '%@' list", list.store_name];
        [actions addObject:[UIAction actionWithTitle:actionTitle image:nil identifier:nil handler:^(__kindof UIAction* _Nonnull action) {
            [[AppState sharedManager] addItemToList:list withItem:self.item withCompletion:^(BOOL succeeded, NSError *error) {
                if(succeeded) {
                    [self performSegueWithIdentifier:@"segueBackToLists" sender:self];
                }
            }];
        }]];
    }
    addItemToListButton.menu = [UIMenu menuWithTitle:@"" children:actions];
    addItemToListButton.showsMenuAsPrimaryAction = YES;
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

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    Price *const price = self.item.prices[indexPath.item];
    __weak __typeof__(self) weakSelf = self;
    [self priceSelected:price withCompletion:^(BOOL succeeded) {
        [weakSelf performSegueWithIdentifier:@"segueFromPriceToList" sender:self];
    }];
    
}

- (void) priceSelected: (Price *)selected withCompletion:(void(^)(BOOL succeeded))completion{
    BOOL listExists = NO;
    for(ShoppingList *list in _lists) {
        if(list.store_name==selected.store) {
            listExists = YES;
            [[AppState sharedManager] addItemToList:list withItem:self.item withCompletion:^(BOOL succeeded, NSError *error) {
                if(succeeded) {
                    completion(YES);
                }
            }];
        }
    }
    if (!listExists) {
        __weak __typeof__(self) weakSelf = self;
        [ShoppingList createEmptyList:selected.store withCompletion:^(ShoppingList * _Nonnull new_list, NSError * _Nonnull error) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if(strongSelf) {
                [[AppState sharedManager] addItemToList:new_list withItem:strongSelf.item withCompletion:^(BOOL succeeded, NSError *error) {
                    if(succeeded) {
                        completion(YES);
                    }
                }];
            }
        }];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqual:@"segueFromPriceToList"]) {
        ShoppingListManagerViewController *const listManagerVC = [segue destinationViewController];
    }
}

@end
