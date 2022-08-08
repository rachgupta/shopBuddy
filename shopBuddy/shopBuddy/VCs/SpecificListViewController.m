//
//  ShoppingListViewController.m
//  shopBuddy
//
//  Created by Rachna Gupta on 7/6/22.
//

#import "SpecificListViewController.h"
#import "ListItemCell.h"
#import "Item.h"
#import "UIImageView+AFNetworking.h"
#import "ShoppingList+Persistent.h"
#import "Item+Persistent.h"
#import "ListItemDetailViewController.h"
#import "Price.h"
#import "AppState.h"

@interface SpecificListViewController () <UITableViewDataSource, UITableViewDelegate>
{
    __weak IBOutlet UITableView *tableView;
    NSArray<Item *> *items;
    
}
@property (weak, nonatomic) IBOutlet UILabel *list_label;

@end

@implementation SpecificListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.rowHeight = UITableViewAutomaticDimension;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.title = [NSString stringWithFormat:@"%@ Shopping List", self.list.store_name];
    items = self.list.items;
    [tableView reloadData];
}

#pragma mark - TableViewDelegate and Data Source methods

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:
    (NSIndexPath *)indexPath {
    ListItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListItemCell"];
    Item *const item = items[indexPath.row];
    cell.itemTitle.text = item.name;
    NSString *const URLString = item.images[0];
    NSURL *const url = [NSURL URLWithString:URLString];
    [cell.itemPhoto setImageWithURL:url];
    NSArray<Price *> *prices = item.prices;
    NSString *label = @"Not Found";
    for (Price *price in prices) {
        if([price.store isEqual:self.list.store_name]) {
            label = [NSString stringWithFormat:@"$%@", [price.price stringValue]];
        }
    }
    cell.priceLabel.text = label;
    cell.addCartButton.tag = indexPath.row;
    [cell.addCartButton addTarget:self action:@selector(didClickAddToCart:) forControlEvents:UIControlEventTouchUpInside];
    cell.addCartButton.clipsToBounds = YES;
    cell.addCartButton.layer.cornerRadius = cell.addCartButton.layer.frame.size.width/2;
    return cell;
}
-(void)didClickAddToCart:(UIButton*)sender
{
    Item *const item = items[sender.tag];
    AppState *const state = [AppState sharedManager];
    __weak __typeof__(self) weakSelf = self;
    [Cart addItemToCart:state.cart withItem:item fromList:self.list withCompletion:^(Cart * _Nonnull updatedCart, NSError * _Nonnull error) {
        if(updatedCart) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if(strongSelf) {
                state.cart = updatedCart;
                [ShoppingList removeItemFromList:strongSelf.list withItem:item withCompletion:^(ShoppingList * _Nonnull new_list, NSError * _Nonnull error) {
                    if(!error) {
                        [weakSelf _showInputAlert:item];
                    }
                }];
            }
        }
    }];
}

- (void)_showInputAlert: (Item *)item{
  AppState *const state = [AppState sharedManager];
  UIAlertController *alertVC=[UIAlertController alertControllerWithTitle:@"How much was the item?" message:@"Please input the price of the item" preferredStyle:UIAlertControllerStyleAlert];
    [alertVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
      {
        textField.placeholder=@"ex. 0.00";
        textField.textColor=[UIColor redColor];
        textField.clearButtonMode=UITextFieldViewModeWhileEditing;
      }
    }];
    __weak __typeof__(self) weakSelf = self;
    UIAlertAction *const action = [UIAlertAction actionWithTitle:@"Price" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSNumber *const newPrice = @([alertVC.textFields[0].text doubleValue]);
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if(strongSelf) {
            [Cart updatePrice:newPrice forItem:item withCart:state.cart withCompletion:^(Cart * _Nonnull cart) {
                if(cart) {
                    state.cart = cart;
                    [strongSelf.navigationController popToRootViewControllerAnimated:YES];
                    [strongSelf.tabBarController setSelectedIndex:2];
                }
            }];
        }
    }];
    [alertVC addAction:action];
    [self presentViewController:alertVC animated:true completion:nil];
}
#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqual:@"showListItemDetail"]) {
        NSIndexPath *const myPath = [tableView indexPathForCell:sender];
        Item *const selected_item = items[myPath.row];
        ListItemDetailViewController *const itemdetailVC = [segue destinationViewController];
        itemdetailVC.item = selected_item;
        itemdetailVC.list = self.list;
    }
}

@end
