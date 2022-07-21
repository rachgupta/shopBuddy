//
//  ShoppingListManagerViewController.m
//  shopBuddy
//
//  Created by Rachna Gupta on 7/18/22.
//

#import "ShoppingListManagerViewController.h"
#import "ShoppingListCell.h"
#import "ShoppingList.h"
#import "SpecificListViewController.h"
#import "ShoppingList+Persistent.h"
@interface ShoppingListManagerViewController () <UITableViewDataSource, UITableViewDelegate>
{
    __weak IBOutlet UITableView *tableView;
    NSArray<ShoppingList*> *lists;
    
}

@end

@implementation ShoppingListManagerViewController

- (void)viewDidLoad {
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.rowHeight = UITableViewAutomaticDimension;
    [self _fetchLists];
    [super viewDidLoad];
}

- (void)_fetchLists {
    PFQuery *query = [PFQuery queryWithClassName:@"ShoppingList"];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *fetched_lists, NSError *error) {
        if (fetched_lists != nil) {
            self->lists = fetched_lists;
            [self->tableView reloadData];
        }
    }];
}

- (IBAction)didTapAddList:(id)sender {
    //TODO: add List names (make List of stores)
    [ShoppingList createEmptyList: @"New_List" withCompletion:^(BOOL succeeded, NSError *error) {}];
    [self _fetchLists];
    
}

#pragma mark - TableViewDelegate and Data Source methods

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return lists.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:
    (NSIndexPath *)indexPath {
    ShoppingListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ShoppingListCell"];
    ShoppingList *const list = lists[indexPath.row];
    cell.store_name.text = list.store_name;
    return cell;
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *const myPath = [tableView indexPathForCell:sender];
    ShoppingList *const selected_list = lists[myPath.row];
    SpecificListViewController *const specificVC = [segue destinationViewController];
    specificVC.list = selected_list;
    // Get the new view controller using [segue destinalujreffivtfhieeftgbblbjifktddrhdreidlkhickcbgfjbtlreikkngbudjrkhtionViewController].
    // Pass the selected object to the new view controller.
}

@end
