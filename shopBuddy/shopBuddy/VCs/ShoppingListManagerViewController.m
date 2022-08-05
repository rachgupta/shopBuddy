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
#import "Parse/Parse.h"
#import "AddItemViewController.h"
#import "AppState.h"
#import "Cart+Persistent.h"
#import "MBProgressHUD/MBProgressHUD.h"

@interface ShoppingListManagerViewController () <UITableViewDataSource, UITableViewDelegate>
{
    __weak IBOutlet UITableView *tableView;
    NSArray<ShoppingList*> *lists;
    NSArray<NSString*> *stores;
    __weak IBOutlet UIButton *addListButton;
    
}

@end

@implementation ShoppingListManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //UINavigationBar *bar = [self.navigationController navigationBar];
    
    //[bar setTintColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0]];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.rowHeight = UITableViewAutomaticDimension;
    
}
- (void) viewWillAppear:(BOOL)animated {
    AppState *manager = [AppState sharedManager];
    stores = @[@"Walmart",@"Target",@"Amazon"];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = @"Loading";
    __weak __typeof__(self) weakSelf = self;
    [manager updateAppState:^(BOOL succeeded) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if(strongSelf) {
            strongSelf->lists = manager.lists;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf _makeMenu];
                [strongSelf->tableView reloadData];
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
        }
    }];
    //Test
}

- (void)_fetchLists {
    [ShoppingList fetchLists:^(NSArray<ShoppingList *> *lists, NSError *error) {
        self->lists = lists;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->tableView reloadData];
        });
    }];
}

- (void) _makeMenu {
    NSMutableArray* actions = [[NSMutableArray alloc] init];
    for (NSString *store in stores) {
        NSString *const actionTitle = [NSString stringWithFormat:@"Add '%@' list", store];
        __weak __typeof__(self) weakSelf = self;
        [actions addObject:[UIAction actionWithTitle:actionTitle image:nil identifier:nil handler:^(__kindof UIAction* _Nonnull action) {
            [ShoppingList createEmptyList:store withCompletion:^(ShoppingList *list,NSError *error) {
                if(!error) {
                    [weakSelf _fetchLists];
                }
            }];
            
        }]];
    }
    addListButton.menu = [UIMenu menuWithTitle:@"" children:actions];
    addListButton.showsMenuAsPrimaryAction = YES;
}

#pragma mark - Actions
- (IBAction)didTapAddItem:(id)sender {
    [self performSegueWithIdentifier:@"segueToAddItem" sender:self];
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
    if([segue.identifier isEqual:@"segueToList"]) {
        NSIndexPath *const myPath = [tableView indexPathForCell:sender];
        ShoppingList *const selected_list = lists[myPath.row];
        SpecificListViewController *const specificVC = [segue destinationViewController];
        specificVC.list = selected_list;
    } else if([segue.identifier isEqual:@"segueToAddItem"]) {
        AddItemViewController *const addVC = [segue destinationViewController];
    }
}

@end
