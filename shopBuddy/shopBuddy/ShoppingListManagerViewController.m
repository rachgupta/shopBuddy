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

@interface ShoppingListManagerViewController () <UITableViewDataSource, UITableViewDelegate,ShoppingListDelegate>
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
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.rowHeight = UITableViewAutomaticDimension;
    __weak __typeof__(self) weakSelf = self;
    stores = @[@"Walmart",@"Target",@"Amazon"];
    [weakSelf _fetchLists];
    [self _makeMenu];
}

- (void)_fetchLists {
    [ShoppingList fetchListsByUser:[PFUser currentUser] withCompletion:^(NSArray<ShoppingList *> *lists, NSError *error) {
        self->lists = lists;
        [self->tableView reloadData];
    }];
}

- (void) _updateListsWithNewList: (ShoppingList *)list {
    BOOL updatingList = NO;
    ShoppingList *list_to_update = nil;
    NSMutableArray *const mutable_lists = [NSMutableArray arrayWithArray:lists];
    for (ShoppingList *old_list in mutable_lists) {
        if(old_list.objectID==list.objectID) {
            updatingList = YES;
            list_to_update = old_list;
        }
    }
    if(list_to_update!=nil) {
        [mutable_lists removeObject:list_to_update];
    }
    [mutable_lists addObject:list];
    lists = mutable_lists;
    [tableView reloadData];
}
- (void) _makeMenu {
    NSMutableArray* actions = [[NSMutableArray alloc] init];
    for (NSString *store in stores) {
        NSString *const actionTitle = [NSString stringWithFormat:@"Add '%@' list", store];
        __weak __typeof__(self) weakSelf = self;
        [actions addObject:[UIAction actionWithTitle:actionTitle image:nil identifier:nil handler:^(__kindof UIAction* _Nonnull action) {
            [ShoppingList createEmptyList:store withCompletion:^(ShoppingList *list,NSError *error) {
                if(!error) {
                    [weakSelf _updateListsWithNewList:list];
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

#pragma mark - Delegate
- (void)addItemToList:(ShoppingList *)list withItem: (Item *)item withCompletion:(void(^)(BOOL succeeded, NSError *error))completion{
    __weak __typeof__(self) weakSelf = self;
    [ShoppingList createFromList:list withItem:item withCompletion:^(ShoppingList* updatedList, NSError *error) {
        if(!error) {
            [weakSelf _updateListsWithNewList:list];
            completion(YES,nil);
        }
        else {
            completion(NO,error);
        }
    }];
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
        addVC.lists = lists;
        addVC.delegate = self;
    }
}

@end
