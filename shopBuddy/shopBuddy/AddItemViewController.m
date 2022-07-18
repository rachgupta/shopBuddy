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
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *barcodeField;
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@end

NSMutableArray<Item*> *searchResults;
@implementation AddItemViewController

- (void)viewDidLoad {
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
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
    [[APIManager shared] getItemWithSearch:self.searchField.text completion:^(NSMutableArray<Item*> *items, NSError *error) {
        searchResults = items;
        [self.tableView reloadData];
    }];
    [self.tableView reloadData];
}
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
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqual:@"showDetailSegue"])
    {
        ItemDetailViewController *detailVC = [segue destinationViewController];
        detailVC.barcode = self.barcodeField.text;
    } else if([segue.identifier isEqual:@"showBarcodeSegue"]) {
        ScanBarcodeViewController *barcodeVC = [segue destinationViewController];
    }
}

@end
