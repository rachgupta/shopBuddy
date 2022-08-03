//
//  HistoryViewController.m
//  shopBuddy
//
//  Created by Rachna Gupta on 8/3/22.
//

#import "HistoryViewController.h"
#import "Trip+Persistent.h"
#import "AppState.h"

@interface HistoryViewController () <UITableViewDataSource, UITableViewDelegate>
{
    __weak IBOutlet UITableView *tableView;
    AppState *manager;
    NSDictionary<NSString *, NSMutableArray<Trip *> *> *organizedData;
    __weak IBOutlet UILabel *totalLabel;
    __weak IBOutlet UILabel *budgetLabel;
}

@end

@implementation HistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.rowHeight = UITableViewAutomaticDimension;
    manager = [AppState sharedManager];
    [self _organizeData:manager.trips];
    [self _calculateTotalStatus];
    // Do any additional setup after loading the view.
}
- (void) _organizeData: (NSArray<Trip *> *)trips {
    NSMutableDictionary *output = [NSMutableDictionary new];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"MM/dd/YY"];
    for (Trip *trip in trips) {
        NSString *dateString = [dateFormatter stringFromDate:trip.purchase_date];
        if(!output[dateString]) {
            output[dateString] = [NSMutableArray new];
        }
        [output[dateString] addObject:trip];
    }
    organizedData = [NSDictionary dictionaryWithDictionary:output];
    [tableView reloadData];
}

- (void) _calculateTotalStatus {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"MM"];
    NSString *current_month = [dateFormatter stringFromDate:[NSDate now]];
    double sum = 0;
    for (NSString *date in [organizedData allKeys]) {
        if([[date substringToIndex:3] isEqualToString:current_month]) {
            for (Trip *trip in organizedData[date]) {
                for (NSNumber *num in [trip.item_prices allValues]) {
                    sum = sum + [num doubleValue];
                }
            }
        }
    }
    totalLabel.text = [NSString stringWithFormat:@"Total This Month: $ %.2f",sum];
    double budget = [[PFUser currentUser][@"budget"] doubleValue];
    double difference = budget - sum;
    budgetLabel.text =[NSString stringWithFormat:@"You;re $ %.2f under budget.",difference];
}

#pragma mark - TableView
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:
    (NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TripCell"];
    NSArray *keys = [organizedData allKeys];
    Trip *const trip = organizedData[keys[indexPath.section]][indexPath.row];
    UILabel *storeLabel = (UILabel *)[cell viewWithTag:1];
    NSArray *stores = [[NSSet setWithArray:[trip.item_store allValues]] allObjects];
    [storeLabel setText:[NSString stringWithFormat:@"Purchased from %@",[stores componentsJoinedByString: @","]]];
    UILabel *itemLabel = (UILabel *)[cell viewWithTag:2];
    [itemLabel setText:[NSString stringWithFormat:@"%lu items",(unsigned long)trip.items.count]];
    UILabel *priceLabel = (UILabel *)[cell viewWithTag:3];
    double sum = 0;
    for (NSNumber *num in [trip.item_prices allValues]) {
        sum = sum + [num doubleValue];
    }
    [priceLabel setText:[NSString stringWithFormat:@"Total: $ %.2f",sum]];
    
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
