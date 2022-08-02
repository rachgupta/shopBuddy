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
- (IBAction)didPressSync:(id)sender {
    [activityIndicator startAnimating];
    GlobalManager *myManager = [GlobalManager sharedManager];
    __weak __typeof__(self) weakSelf = self;
    [myManager refreshPricesForItem:self.item fromStore:@"google_shopping" completion:^(NSArray<Price *> * _Nonnull prices, BOOL success) {
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

- (IBAction)didPressAddToList:(id)sender {
    AppState *state = [AppState sharedManager];
    __weak __typeof__(self) weakSelf = self;
    [Cart addItemToCart:state.cart withItem:self.item withCompletion:^(Cart * _Nonnull updatedCart, NSError * _Nonnull error) {
        if(updatedCart) {
            state.cart = updatedCart;
            NSLog(@"success");
            [weakSelf performSegueWithIdentifier:@"segueToCart" sender:self];
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

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    Price *const price = self.item.prices[indexPath.item];
    __weak __typeof__(self) weakSelf = self;
    [self priceSelected:price withCompletion:^(BOOL succeeded) {
        if(YES) {
            [weakSelf performSegueWithIdentifier:@"segueFromPriceToList" sender:self];
        }
    }];
    
}

- (void) priceSelected: (Price *)selected withCompletion:(void(^)(BOOL succeeded))completion{
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
        //test
    }];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqual:@"segueFromPriceToList"]) {
        ShoppingListManagerViewController *const listManagerVC = [segue destinationViewController];
    }
}

@end
