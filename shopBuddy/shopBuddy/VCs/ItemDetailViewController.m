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
    NSNumber *lowest_price;
    BOOL doneLoading;
    
}

@end

@implementation ItemDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    doneLoading = NO;
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
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Item Not Found" message:@"The scanned item is not found. Please try with a different item. " preferredStyle:(UIAlertControllerStyleAlert)];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){}];
            [alert addAction:okAction];
            [weakSelf presentViewController:alert animated:YES completion:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf _popToRoot];
                });
            }];
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
                [weakSelf _pricesFetched];
            });
        }
    }];
}

- (void) _pricesFetched {
    if(self.item.prices.count>0) {
        lowest_price = self.item.prices[0].price;
        for (Price *price in self.item.prices) {
            if ([price.price doubleValue]<[lowest_price doubleValue]) {
                lowest_price = price.price;
            }
        }
    }
    [activityIndicator stopAnimating];
    doneLoading = YES;
    [collectionView reloadData];
}

- (void) _popToRoot {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)_populateView {
    //TODO: add Show More button and shortened description
    self.title = self.item.name;
    titleLabel.text = self.item.name;
    brandLabel.text = self.item.brand;
    descriptionView.text = self.item.item_description;
    NSString *const URLString = self.item.images[0];
    NSURL *const url = [NSURL URLWithString:URLString];
    [itemImage setImageWithURL:url];
}

- (void) _makeMenu {
    NSMutableArray* actions = [[NSMutableArray alloc] init];
    __weak __typeof__(self) weakSelf = self;
    for (ShoppingList *list in self.lists) {
        NSString *const actionTitle = [NSString stringWithFormat:@"Add Item to '%@' list", list.store_name];
        [actions addObject:[UIAction actionWithTitle:actionTitle image:nil identifier:nil handler:^(__kindof UIAction* _Nonnull action) {
            [[AppState sharedManager] addItemToList:list withItem:self.item withCompletion:^(BOOL succeeded, NSError *error) {
                if(succeeded) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf _popToRoot];
                    });
                }
            }];
        }]];
    }
    addItemToListButton.menu = [UIMenu menuWithTitle:@"" children:actions];
    addItemToListButton.showsMenuAsPrimaryAction = YES;
}


//adds item to list if price selected
- (void) _priceSelected: (Price *)selected withCompletion:(void(^)(BOOL succeeded))completion{
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
#pragma mark - CollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if(doneLoading) {
        if(self.item.prices.count==0) {
            return 1;
        }
    }
    return self.item.prices.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PriceCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PriceCell" forIndexPath:indexPath];
    if(doneLoading) {
        if(self.item.prices.count>0) {
            Price *const price = self.item.prices[indexPath.item];
            cell.storeLabel.text = price.store;
            cell.priceLabel.text = [NSString stringWithFormat:@"$ %.2f",[price.price doubleValue]];
            if([price.price doubleValue]==[lowest_price doubleValue]) {
                cell.contentView.backgroundColor = [UIColor colorWithRed: 0.64 green: 0.86 blue: 0.55 alpha: 1.00];;
            }
        }
        else {
            cell.storeLabel.text = @"No Prices Found";
            cell.priceLabel.text = @" ";
        }
        cell.layer.masksToBounds = YES;
        cell.layer.cornerRadius = 10;
    }
    return cell;
}

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if(self.item.prices.count>0) {
        Price *const price = self.item.prices[indexPath.item];
        __weak __typeof__(self) weakSelf = self;
        [self _priceSelected:price withCompletion:^(BOOL succeeded) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf _popToRoot];
            });
        }];
    }
}

@end
