//
//  AddItemViewController.m
//  shopBuddy
//
//  Created by Rachna Gupta on 7/12/22.
//

#import "AddItemViewController.h"
#import "BarcodeAPIManager.h"
#import "Item+Persistent.h"
#import "ItemDetailViewController.h"
#import "ScanBarcodeViewController.h"
#import "SearchResultItemCell.h"
#import "UIImageView+AFNetworking.h"

@interface AddItemViewController () <UITableViewDataSource, UITableViewDelegate,UIPickerViewDelegate,UIPickerViewDataSource>
@end
@implementation AddItemViewController {
    UITextField *_searchField;
    NSMutableDictionary<NSString*,NSMutableArray<Item*> *> *searchResults;
    NSMutableDictionary<NSString*,NSMutableArray<Item*> *> *all_searchResults;
    UITextField *_barcodeField;
    UITableView *_tableView;
    __weak IBOutlet UITextField *pickerViewField;
    NSArray<NSString*> *categories;
}

- (void)viewDidLoad {
    //categories = [@[@"Animals & Pet Supplies",@"Apparel & Accessories", @"Arts & Entertainment", @"Baby & Toddler", @"Business & Industrial",@"Cameras & Optics",@"Electronics",@"Food, Beverages & Tobacco",@"Furniture",@"Hardware",@"Health & Beauty",@"Home & Garden",@"Luggage & Bags",@"Mature",@"Media",@"Office Supplies",@"Religious & Ceremonial",@"Software",@"Sporting Goods",@"Toys & Games",@"Vehicles & Parts",] mutableCopy];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.rowHeight = UITableViewAutomaticDimension;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [super viewDidLoad];
    UIPickerView *picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 50, 100, 150)];
    [picker setDataSource: self];
    [picker setDelegate: self];
    pickerViewField.inputView = picker;
}

- (IBAction)didTapScanBarcode:(id)sender {
    [self performSegueWithIdentifier:@"showBarcodeSegue" sender:self];
}

- (IBAction)didTapSearch:(id)sender {
    __weak __typeof__(self) weakSelf = self;
    [[BarcodeAPIManager shared] searchItemsWithQuery:_searchField.text completion:^(NSMutableArray<Item*> *items, NSError *error) {
        if(items) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if(strongSelf)
            {
                //strongSelf->_searchResults = items;
                NSMutableDictionary *local_results = [NSMutableDictionary new];
                for (Item *item in items) {
                    local_results[item.category] = [NSMutableArray new];
                }
                for (Item *item in items) {
                    [local_results[item.category] addObject:item];
                }
                strongSelf->searchResults = local_results;
                strongSelf->all_searchResults = local_results;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf _reloadData];
                });
            }
        }
        else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Item Not Found" message:@"The searched item is not found." preferredStyle:(UIAlertControllerStyleAlert)];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){}];
            [alert addAction:okAction];
            [weakSelf presentViewController:alert animated:YES completion:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf _backToLists];
                });
            }];
        }
    }];
}

- (void)_reloadData {
    [_tableView reloadData];
}

- (void)_backToLists {
    [self.navigationController popToRootViewControllerAnimated:YES];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqual:@"showDetailSegue"]) {
        ItemDetailViewController *const detailVC = [segue destinationViewController];
        detailVC.barcode = _barcodeField.text;
    } else if([segue.identifier isEqual:@"showBarcodeSegue"]) {
        ScanBarcodeViewController *const barcodeVC = [segue destinationViewController];
    } else if([segue.identifier isEqual:@"showResultDetailSegue"]) {
        NSIndexPath *const myPath = [_tableView indexPathForCell:sender];
        Item *const selected_item = searchResults[[searchResults allKeys][myPath.section]][myPath.row];
        ItemDetailViewController *const detailVC = [segue destinationViewController];
        detailVC.item = selected_item;
    }
}
#pragma mark - UIPickerView
// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [all_searchResults allKeys].count;
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component API_UNAVAILABLE(tvos) {
    return [all_searchResults allKeys][row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component API_UNAVAILABLE(tvos) {
    pickerViewField.text = [all_searchResults allKeys][row];
    NSMutableDictionary *new_dict = [NSMutableDictionary new];
    new_dict[[all_searchResults allKeys][row]] = all_searchResults[[all_searchResults allKeys][row]];
    searchResults = new_dict;
    [self _reloadData];
}

#pragma mark - TableViewDelegate and Data Source methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:
    (NSIndexPath *)indexPath {
    SearchResultItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ResultCell"];
    Item *const item = searchResults[[searchResults allKeys][indexPath.section]][indexPath.row];
    cell.itemTitle.text = item.name;
    NSString *const URLString = item.images[0];
    NSURL *const url = [NSURL URLWithString:URLString];
    [cell.itemPhoto setImageWithURL:url];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewCell *header = [tableView dequeueReusableCellWithIdentifier:@"TableViewHeaderView"];
    UILabel *label = (UILabel *)[header viewWithTag:123];
    [label setText:[searchResults allKeys][section]];
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 35;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [searchResults allKeys].count;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return searchResults[[searchResults allKeys][section]].count;
}

@end
