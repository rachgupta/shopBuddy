//
//  AddItemViewController.m
//  shopBuddy
//
//  Created by Rachna Gupta on 7/12/22.
//

#import "AddItemViewController.h"
#import "BarcodeAPIManager.h"
#import "Item.h"
#import "ItemDetailViewController.h"
#import "ScanBarcodeViewController.h"
#import "SearchResultItemCell.h"
#import "UIImageView+AFNetworking.h"

@interface AddItemViewController () <UITableViewDataSource, UITableViewDelegate>
@end

@implementation AddItemViewController {
    UITextField *_searchField;
    NSMutableArray<Item*> *_searchResults;
    UITextField *_barcodeField;
    UITableView *_tableView;
}

- (void)viewDidLoad {
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.rowHeight = UITableViewAutomaticDimension;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [super viewDidLoad];
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
                strongSelf->_searchResults = items;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [strongSelf->_tableView reloadData];
                });
            }
        }
        else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Item Not Found" message:@"The searched item is not found." preferredStyle:(UIAlertControllerStyleAlert)];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){}];
            [alert addAction:okAction];
            [weakSelf presentViewController:alert animated:YES completion:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.navigationController popToRootViewControllerAnimated:YES];
                });
            }];
        }
    }];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqual:@"showDetailSegue"]) {
        ItemDetailViewController *const detailVC = [segue destinationViewController];
        detailVC.barcode = _barcodeField.text;
    } else if([segue.identifier isEqual:@"showBarcodeSegue"]) {
        ScanBarcodeViewController *const barcodeVC = [segue destinationViewController];
    } else if([segue.identifier isEqual:@"showResultDetailSegue"]) {
        NSIndexPath *const myPath = [_tableView indexPathForCell:sender];
        Item *const selected_item = _searchResults[myPath.row];
        ItemDetailViewController *const detailVC = [segue destinationViewController];
        detailVC.item = selected_item;
    }
}
#pragma mark - TableViewDelegate and Data Source methods

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _searchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:
    (NSIndexPath *)indexPath {
    SearchResultItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ResultCell"];
    Item *const item = _searchResults[indexPath.row];
    cell.itemTitle.text = item.name;
    NSString *const URLString = item.images[0];
    NSURL *const url = [NSURL URLWithString:URLString];
    [cell.itemPhoto setImageWithURL:url];
    return cell;
}

@end
