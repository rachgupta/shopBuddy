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
    [self _fetchItems];
}
- (void)_fetchItems {
    PFQuery *query = [PFQuery queryWithClassName:@"Item"];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"list" equalTo:self.list];
    [query findObjectsInBackgroundWithBlock:^(NSArray *fetched_items, NSError *error) {
        if (fetched_items != nil) {
            self->items = fetched_items;
            [self->tableView reloadData];
        }
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
    cell.itemTitle.text = item[@"name"];
    NSString *const URLString = item.images[0];
    NSURL *const url = [NSURL URLWithString:URLString];
    [cell.itemPhoto setImageWithURL:url];
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
