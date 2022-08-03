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
    NSDictionary<NSString *, NSMutableArray<Item *> *> *organizedData;
    __weak IBOutlet UILabel *totalLabel;
}

@end

@implementation CartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.rowHeight = UITableViewAutomaticDimension;
    manager = [AppState sharedManager];
    [self _updateView];
    // Do any additional setup after loading the view.
}

- (void) viewWillAppear {
    [self _updateView];
}

- (void) _organizeData {
    NSArray *stores = [[NSSet setWithArray:[manager.cart.item_store allValues]] allObjects];
    NSMutableDictionary *output = [NSMutableDictionary new];
    for (NSString *store in stores) {
        NSArray *item_ids = [manager.cart.item_store allKeysForObject:store];
        output[store] = [NSMutableArray new];
        for (Item *item in items) {
            if([item_ids containsObject:item.objectID]) {
                [output[store] addObject:item];
            }
        }
    }
    organizedData = [NSDictionary dictionaryWithDictionary:output];
}

- (void) _updateView {
    items = manager.cart.items;
    [self _organizeData];
    [tableView reloadData];
    double sum = 0;
    for (NSNumber *num in [manager.cart.item_prices allValues]) {
        sum = sum + [num doubleValue];
    }
    totalLabel.text = [NSString stringWithFormat:@"Total: $%@",[[NSNumber numberWithDouble:sum] stringValue]];
    
}

#pragma mark - TableView
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:
    (NSIndexPath *)indexPath {
    CartItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CartItemCell"];
    NSArray *keys = [organizedData allKeys];
    Item *const item = organizedData[keys[indexPath.section]][indexPath.row];
    cell.itemTitle.text = item.name;
    NSString *const URLString = item.images[0];
    NSURL *const url = [NSURL URLWithString:URLString];
    [cell.itemPhoto setImageWithURL:url];
    cell.itemPrice.text = [NSString stringWithFormat:@"$%@",[manager.cart.item_prices[item.objectID] stringValue]];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewCell *header = [tableView dequeueReusableCellWithIdentifier:@"TableViewHeaderView"];
    NSArray *keys = [organizedData allKeys];
    UILabel *label = (UILabel *)[header viewWithTag:123];
    [label setText:keys[section]];
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 35;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [organizedData allKeys].count;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *keys = [organizedData allKeys];
    return organizedData[keys[section]].count;
}

@end
