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
    _list_label.text = [NSString stringWithFormat:@"%@ Shopping List", self.list.store_name];
    [self.list fetchItemsInList:^(NSArray<Item *> *items, NSError *error) {
        self->items = items;
        [self->tableView reloadData];
    }];
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
        if(price.store == self.list.store_name) {
            label = [NSString stringWithFormat:@"$%@", [price.price stringValue]];
        }
    }
    cell.priceLabel.text = label;
    return cell;
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
