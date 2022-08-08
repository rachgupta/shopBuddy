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
#import "GlobalManager.h"
#import "AppState.h"
#import "ShoppingListManagerViewController.h"
#import "Cart+Persistent.h"

@interface ListItemDetailViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
{
    
    __weak IBOutlet UIImageView *itemImage;
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UILabel *brandLabel;
    __weak IBOutlet UITextView *descriptionView;
    __weak IBOutlet UILabel *listLabel;
    __weak IBOutlet UICollectionView *collectionView;
    __weak IBOutlet UIActivityIndicatorView *activityIndicator;
    AppState *state;
    
    
}

@end

@implementation ListItemDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    state = [AppState sharedManager];
    [self _populateView];
    descriptionView.scrollEnabled=YES;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    self.title = self.item.name;
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector (_addToCart:)];
    doubleTap.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTap];
    // Do any additional setup after loading the view.
}

- (void) _addToCart:(id)sender {
    __weak __typeof__(self) weakSelf = self;
    [Cart addItemToCart:state.cart withItem:self.item fromList:self.list withCompletion:^(Cart * _Nonnull updatedCart, NSError * _Nonnull error) {
        if(updatedCart) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if(strongSelf) {
                strongSelf->state.cart = updatedCart;
                [ShoppingList removeItemFromList:strongSelf.list withItem:strongSelf.item withCompletion:^(ShoppingList * _Nonnull new_list, NSError * _Nonnull error) {
                    if(!error) {
                        [weakSelf _showInputAlert];
                    }
                }];
            }
        }
    }];
}

- (void)_showInputAlert {
  UIAlertController *alertVC=[UIAlertController alertControllerWithTitle:@"How much was the item?" message:@"Please input the price of the item" preferredStyle:UIAlertControllerStyleAlert];
    [alertVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
      {
        NSArray<Price *> *prices = self.item.prices;
          for (Price *price in prices) {
              if([price.store isEqual:self.list.store_name]) {
                  textField.placeholder=[NSString stringWithFormat:@"%.2f",[price.price doubleValue]];
              }
          }
        textField.textColor=[UIColor redColor];
        textField.clearButtonMode=UITextFieldViewModeWhileEditing;
      }
    }];
    __weak __typeof__(self) weakSelf = self;
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Price" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSNumber *const newPrice = @([alertVC.textFields[0].text doubleValue]);
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if(strongSelf) {
            [Cart updatePrice:newPrice forItem:strongSelf.item withCart:strongSelf->state.cart withCompletion:^(Cart * _Nonnull cart) {
                if(cart) {
                    strongSelf->state.cart = cart;
                    [self.navigationController popToRootViewControllerAnimated:YES];
                    [self.tabBarController setSelectedIndex:2];
                    //[weakSelf performSegueWithIdentifier:@"segueToCart" sender:self];
                }
            }];
        }
    }];
    [alertVC addAction:action];
    [self presentViewController:alertVC animated:true completion:nil];
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

- (void) _priceSelected: (Price *)selected withCompletion:(void(^)(BOOL succeeded))completion{
    __weak __typeof__(self) weakSelf = self;
    [ShoppingList removeItemFromList:self.list withItem:self.item withCompletion:^(ShoppingList * _Nonnull new_list, NSError * _Nonnull error) {
        if(!error) {
            BOOL listExists = NO;
            AppState *state = [AppState sharedManager];
            for(ShoppingList *list in state.lists) {
                if([list.store_name isEqual:selected.store]) {
                    listExists = YES;
                    __strong __typeof(weakSelf)strongSelf = weakSelf;
                    if(strongSelf) {
                        [ShoppingList addExistingItem:strongSelf.item toList:list withCompletion:^(Item * _Nonnull item, NSError * _Nonnull error) {
                            if(!error) {
                                completion(YES);
                            }
                            else {
                                completion(NO);
                            }
                        }];
                    }
                }
            }
            if (!listExists) {
                [ShoppingList createEmptyList:selected.store withCompletion:^(ShoppingList * _Nonnull new_list, NSError * _Nonnull error) {
                    __strong __typeof(weakSelf)strongSelf = weakSelf;
                    if(strongSelf) {
                        [ShoppingList addExistingItem:strongSelf.item toList:new_list withCompletion:^(Item * _Nonnull item, NSError * _Nonnull error) {
                            if(item) {
                                completion(YES);
                            }
                            else {
                                completion(NO);
                            }
                        }];
                    }
                }];
            }
        }
    }];
}

- (void) _reloadCollection {
    [collectionView reloadData];
}

- (void) _stopAnimating {
    [activityIndicator stopAnimating];
}

- (void) _popToRoot {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - Actions
- (IBAction)didPressSync:(id)sender {
    [activityIndicator startAnimating];
    GlobalManager *myManager = [GlobalManager sharedManager];
    __weak __typeof__(self) weakSelf = self;
    [myManager refreshPricesForItem:self.item fromStore:@"google_shopping" completion:^(NSArray<Price *> * _Nonnull prices, BOOL success) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if(strongSelf) {
            [strongSelf.item syncPrices:prices];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf _stopAnimating];
                [weakSelf _reloadCollection];
            });
        }
        
    }];
}
- (IBAction)didPressAddToCart:(id)sender {
    [self _addToCart:sender];
}

#pragma mark - Collection View
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if(self.item.prices.count==0) {
        return 1;
    }
    return self.item.prices.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PriceCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PriceCell" forIndexPath:indexPath];
    if(self.item.prices.count>0) {
        Price *const price = self.item.prices[indexPath.item];
        cell.storeLabel.text = price.store;
        cell.priceLabel.text = [NSString stringWithFormat:@"$ %.2f",[price.price doubleValue]];
    }
    else {
        cell.storeLabel.text = @"No Prices Found";
        cell.priceLabel.text = @" ";
    }
    cell.layer.cornerRadius = 15;
    cell.layer.borderWidth = 0.0;
    return cell;
}

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if(self.item.prices.count>0) {
        Price *const price = self.item.prices[indexPath.item];
        __weak __typeof__(self) weakSelf = self;
        [self _priceSelected:price withCompletion:^(BOOL succeeded) {
            if(YES) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf _popToRoot];
                });
            }
        }];
    }
}

@end
