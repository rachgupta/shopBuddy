//
//  TripViewController.m
//  Pods
//
//  Created by Rachna Gupta on 8/9/22.
//

#import "TripViewController.h"
#import "UIImageView+AFNetworking.h"

@interface TripViewController () <UITableViewDataSource, UITableViewDelegate>
{
    __weak IBOutlet UITableView *tableView;
    NSDictionary<NSString *, NSMutableArray<Item *> *> *organizedData;
    __weak IBOutlet UILabel *dateLabel;
    __weak IBOutlet UILabel *totalLabel;
    __weak IBOutlet UILabel *totalCouldHaveLabel;
}

@end

@implementation TripViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.rowHeight = UITableViewAutomaticDimension;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self _organizeData];
    [self _updateLabels];
    [tableView reloadData];
    // Do any additional setup after loading the view.
}

- (void) _updateLabels {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"MM/dd/YY"];
    dateLabel.text = [NSString stringWithFormat:@"Trip completed on %@",[dateFormatter stringFromDate:self.trip.purchase_date]];
    double sum = 0;
    for (NSNumber *num in [self.trip.item_prices allValues]) {
        sum = sum + [num doubleValue];
    }
    totalLabel.text = [NSString stringWithFormat:@"Total: $ %.2f",sum];
    if([self.trip.totalCouldHaveSaved doubleValue]>0) {
        totalCouldHaveLabel.text = [NSString stringWithFormat:@"Total ShopBuddy could have saved you: $ %.2f",[self.trip.totalCouldHaveSaved doubleValue]];
    }
    else {
        totalCouldHaveLabel.text = @"";
    }
}

- (void) _organizeData {
    NSArray *stores = [[NSSet setWithArray:[self.trip.item_store allValues]] allObjects];
    NSMutableDictionary *output = [NSMutableDictionary new];
    for (NSString *store in stores) {
        NSArray *item_ids = [self.trip.item_store allKeysForObject:store];
        output[store] = [NSMutableArray new];
        for (Item *item in self.trip.items) {
            if([item_ids containsObject:item.objectID]) {
                [output[store] addObject:item];
            }
        }
    }
    organizedData = [NSDictionary dictionaryWithDictionary:output];
}
#pragma mark - TableView
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:
    (NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TripItemCell"];
    NSArray *keys = [organizedData allKeys];
    Item *const item = organizedData[keys[indexPath.section]][indexPath.row];
    UILabel *itemTitle = (UILabel *)[cell viewWithTag:2];
    [itemTitle setText:item.name];
    NSString *const URLString = item.images[0];
    NSURL *const url = [NSURL URLWithString:URLString];
    UIImageView *itemPhoto = (UIImageView *)[cell viewWithTag:1];
    [itemPhoto setImageWithURL:url];
    UILabel *priceLabel = (UILabel *)[cell viewWithTag:3];
    [priceLabel setText:[NSString stringWithFormat:@"$ %.2f",[self.trip.item_prices[item.objectID] doubleValue]]];
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
