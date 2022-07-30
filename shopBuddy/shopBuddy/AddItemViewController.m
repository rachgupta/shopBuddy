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
    [super viewDidLoad];
}

- (IBAction)didTapScanBarcode:(id)sender {
    [self performSegueWithIdentifier:@"showBarcodeSegue" sender:self];
}

- (IBAction)didTapSearch:(id)sender {
    //TODO: Search field validation
    [[BarcodeAPIManager shared] searchItemsWithQuery:_searchField.text completion:^(NSMutableArray<Item*> *items, NSError *error) {
        //TODO: handle error
        self->_searchResults = items;
        [self->_tableView reloadData];
    }];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqual:@"showDetailSegue"]) {
        ItemDetailViewController *const detailVC = [segue destinationViewController];
        detailVC.delegate = self.delegate;
        detailVC.lists = self.lists;
        detailVC.barcode = _barcodeField.text;
    } else if([segue.identifier isEqual:@"showBarcodeSegue"]) {
        ScanBarcodeViewController *const barcodeVC = [segue destinationViewController];
        barcodeVC.delegate = self.delegate;
        barcodeVC.lists = self.lists;
    } else if([segue.identifier isEqual:@"showResultDetailSegue"]) {
        NSIndexPath *const myPath = [_tableView indexPathForCell:sender];
        Item *const selected_item = _searchResults[myPath.row];
        ItemDetailViewController *const detailVC = [segue destinationViewController];
        detailVC.item = selected_item;
        detailVC.delegate = self.delegate;
        detailVC.lists = self.lists;
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
