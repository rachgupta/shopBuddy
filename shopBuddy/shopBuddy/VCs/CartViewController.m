//
//  CartViewController.m
//  shopBuddy
//
//  Created by Rachna Gupta on 8/1/22.
//

#import "CartViewController.h"
#import "Item+Persistent.h"
#import "CartItemCell.h"
#import "UIImageView+AFNetworking.h"
#import "AppState.h"

@interface CartViewController () <UITableViewDataSource, UITableViewDelegate>
{
    __weak IBOutlet UITableView *tableView;
    NSArray<Item *> *items;
    AppState *manager;
}

@end

@implementation CartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.rowHeight = UITableViewAutomaticDimension;
    manager = [AppState sharedManager];
    [self _fetchItems];
    // Do any additional setup after loading the view.
}

- (void) viewWillAppear {
    [self _fetchItems];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return items.count;
}

- (void) _fetchItems {
    items = manager.cart.items;
    [tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:
    (NSIndexPath *)indexPath {
    CartItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CartItemCell"];
    Item *const item = items[indexPath.row];
    cell.itemTitle.text = item.name;
    NSString *const URLString = item.images[0];
    NSURL *const url = [NSURL URLWithString:URLString];
    [cell.itemPhoto setImageWithURL:url];
    cell.itemPrice.text = [manager.cart.item_prices[item.objectID] stringValue];
    return cell;
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
