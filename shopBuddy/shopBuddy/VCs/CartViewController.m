//
//  CartViewController.m
//  shopBuddy
//
//  Created by Rachna Gupta on 8/1/22.
//

#import "CartViewController.h"
#import "Item+Persistent.h"
#import "CartItemCell.h"
#import "UIImageView+AFNetworking.h"
#import "AppState.h"
#import "Trip+Persistent.h"

@interface CartViewController () <UITableViewDataSource, UITableViewDelegate>
{
    __weak IBOutlet UITableView *tableView;
    NSArray<Item *> *items;
    AppState *manager;
    NSDictionary<NSString *, NSMutableArray<Item *> *> *organizedData;
    __weak IBOutlet UILabel *totalLabel;
    __weak IBOutlet UIView *animationView;
}

@end

@implementation CartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.rowHeight = UITableViewAutomaticDimension;
    manager = [AppState sharedManager];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    __weak __typeof__(self) weakSelf = self;
    [UIView animateWithDuration:0.2 animations:^{
        self->animationView.frame = CGRectMake(screenRect.size.width, animationView.frame.origin.y, animationView.frame.size.width, animationView.frame.size.height);
    } completion:^(BOOL finished) {
        [weakSelf _updateView:^(BOOL succeeded) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf _reloadTable];
            });
        }];
    }];
    // Do any additional setup after loading the view.
}

- (void) _reloadTable {
    [tableView reloadData];
}

- (void) viewWillAppear: (BOOL)animated {
    __weak __typeof__(self) weakSelf = self;
    [self _updateView:^(BOOL succeeded) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf _reloadTable];
        });
    }];
}

- (void) _closeCartAnimation {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    __weak __typeof__(self) weakSelf = self;
    [UIView animateWithDuration:0.2 animations:^{
        self->animationView.frame = CGRectMake(screenRect.size.width+50, self->animationView.frame.origin.y, -self->animationView.frame.size.width, self->animationView.frame.size.height);
    } completion:^(BOOL finished) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if(strongSelf) {
            [strongSelf.tabBarController setSelectedIndex:3];
        }
    }];
}

- (void) _organizeData {
    NSArray *stores = [[NSSet setWithArray:[manager.cart.item_store allValues]] allObjects];
    NSMutableDictionary *output = [NSMutableDictionary new];
    for (NSString *store in stores) {
        NSArray *item_ids = [manager.cart.item_store allKeysForObject:store];
        output[store] = [NSMutableArray new];
        for (Item *item in items) {
            if([item_ids containsObject:item.objectID]) {
                [output[store] addObject:item];
            }
        }
    }
    organizedData = [NSDictionary dictionaryWithDictionary:output];
}

- (void) _updateView:(void(^)(BOOL succeeded))completion {
    __weak __typeof__(self) weakSelf = self;
    [Cart fetchCurrentCart:^(Cart * _Nonnull cart, NSError * _Nonnull error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if(strongSelf) {
            strongSelf->items = strongSelf->manager.cart.items;
            [weakSelf _organizeData];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf _setTotal];
            });
            completion(YES);
        }
    }];
}

- (void) _setTotal {
    double sum = 0;
    for (NSNumber *num in [manager.cart.item_prices allValues]) {
        sum = sum + [num doubleValue];
    }
    totalLabel.text = [NSString stringWithFormat:@"Total: $ %.2f",sum];
}
- (IBAction)didCheckout:(id)sender {
    __weak __typeof__(self) weakSelf = self;
    [Trip createTripFromCart:manager.cart withCompletion:^(Trip * _Nonnull new_trip, NSError * _Nonnull error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if(strongSelf) {
            NSArray<Trip *> *const old_trips = strongSelf->manager.trips;
            NSMutableArray<Trip *> *const new_trips = [NSMutableArray arrayWithArray:old_trips];
            [new_trips addObject:new_trip];
            strongSelf->manager.trips = new_trips;
            [Cart emptyCart:strongSelf->manager.cart withCompletion:^(Cart * _Nonnull new_cart, NSError * _Nonnull error) {
                strongSelf->manager.cart = new_cart;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf _closeCartAnimation];
                });
            }];
        }
    }];
}

#pragma mark - TableView
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:
    (NSIndexPath *)indexPath {
    CartItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CartItemCell"];
    NSArray *keys = [organizedData allKeys];
    Item *const item = organizedData[keys[indexPath.section]][indexPath.row];
    cell.itemTitle.text = item.name;
    NSString *const URLString = item.images[0];
    NSURL *const url = [NSURL URLWithString:URLString];
    [cell.itemPhoto setImageWithURL:url];
    cell.itemPrice.text = [NSString stringWithFormat:@"$ %.2f",[manager.cart.item_prices[item.objectID] doubleValue]];
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
