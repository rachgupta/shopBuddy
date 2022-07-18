//
//  AddItemViewController.m
//  shopBuddy
//
//  Created by Rachna Gupta on 7/12/22.
//

#import "AddItemViewController.h"
#import "APIManager.h"
#import "Item.h"
#import "ItemDetailViewController.h"
#import "ScanBarcodeViewController.h"
#import "ResultCell.h"
#import "UIImageView+AFNetworking.h"

@interface AddItemViewController () <UITableViewDataSource, UITableViewDelegate>
{
    UITableView *tableView;
    UITextField *barcodeField;
    UITextField *searchField;
    NSMutableArray<Item*> *searchResults;
}

@end

@implementation AddItemViewController

- (void)viewDidLoad {
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.rowHeight = UITableViewAutomaticDimension;
    [super viewDidLoad];
}

- (IBAction)didTapScanBarcode:(id)sender {
    [self performSegueWithIdentifier:@"showBarcodeSegue" sender:self];
}

- (IBAction)didTapGetItem:(id)sender {
    [self performSegueWithIdentifier:@"showDetailSegue" sender:self];
    
}

- (IBAction)didTapSearch:(id)sender {
    //TODO: Search field validation
    [[APIManager shared] getItemWithSearch:searchField.text completion:^(NSMutableArray<Item*> *items, NSError *error) {
        self->searchResults = items;
        [self->tableView reloadData];
    }];
    
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqual:@"showDetailSegue"])
    {
        ItemDetailViewController *detailVC = [segue destinationViewController];
        detailVC.barcode = barcodeField.text;
    } else if([segue.identifier isEqual:@"showBarcodeSegue"]) {
        ScanBarcodeViewController *barcodeVC = [segue destinationViewController];
    } else if([segue.identifier isEqual:@"showResultDetailSegue"]) {
        NSIndexPath *myPath = [tableView indexPathForCell:sender];
        Item *selected_item = searchResults[myPath.row];
        ItemDetailViewController *detailVC = [segue destinationViewController];
        detailVC.item = selected_item;
        detailVC.hasItemPopulated = YES;
    }
}
#pragma mark - TableViewDelegate and Data Source methods

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return searchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:
    (NSIndexPath *)indexPath {
    ResultCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ResultCell"];
    Item *item = searchResults[indexPath.row];
    cell.itemTitle.text = item.name;
    NSString *URLString = item.images[0];
    NSURL *url = [NSURL URLWithString:URLString];
    [cell.itemPhoto setImageWithURL:url];
    return cell;
}

@end
