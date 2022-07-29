//
//  ItemDetailViewController.m
//  shopBuddy
//
//  Created by Rachna Gupta on 7/11/22.
//

#import "ItemDetailViewController.h"
#import "Item.h"
#import "UIImageView+AFNetworking.h"
#import "BarcodeAPIManager.h"
#import "ShoppingList.h"
#import "ShoppingList+Persistent.h"
#import "Parse/Parse.h"
#import "GlobalManager.h"

@interface ItemDetailViewController ()
{
    __weak IBOutlet UITextView *descriptionView;
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UILabel *brandLabel;
    __weak IBOutlet UIImageView *itemImage;
    __weak IBOutlet UIButton *addItemToListButton;
    
}

@end

@implementation ItemDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    descriptionView.scrollEnabled=YES;
    GlobalManager *myManager = [GlobalManager sharedManager];
    [self _callPricesAPI:myManager];
    if (self.item != nil) {
        [self _populateView];
    } else {
        [self _callBarcodeAPI];
    }
    __weak __typeof__(self) weakSelf = self;
    if (self.lists==nil) {
        [ShoppingList fetchListsByUser:[PFUser currentUser] withCompletion:^(NSArray *lists, NSError *error) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if(strongSelf) {
                strongSelf->_lists = lists;
                [weakSelf _makeMenu];
            }
        }];
    } else {
        [self _makeMenu];
    }
}

- (void)_callBarcodeAPI {
    __weak __typeof__(self) weakSelf = self;
    [[BarcodeAPIManager shared] getItemWithBarcode:self.barcode completion:^(Item *item, NSError *error) {
        if (item) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if(strongSelf)
            {
                strongSelf->_item = item;
                [weakSelf _populateView];
            }
        } else {
            //TODO: Failure logic
        }
    }];
}

- (void) _callPricesAPI: (GlobalManager *)manager{
    [manager fetchPricesWithItem:self.item fromStore:@"google_shopping" completion:^(NSDictionary * _Nonnull prices, BOOL success) {}];
}

- (void)_populateView {
    //TODO: add Show More button and shortened description
    titleLabel.text = self.item.name;
    brandLabel.text = self.item.brand;
    descriptionView.text = self.item.item_description;
    NSString *const URLString = self.item.images[0];
    NSURL *const url = [NSURL URLWithString:URLString];
    [itemImage setImageWithURL:url];
}

- (void) _makeMenu {
    NSMutableArray* actions = [[NSMutableArray alloc] init];
    for (ShoppingList *list in self.lists) {
        NSString *const actionTitle = [NSString stringWithFormat:@"Add Item to '%@' list", list.store_name];
        [actions addObject:[UIAction actionWithTitle:actionTitle image:nil identifier:nil handler:^(__kindof UIAction* _Nonnull action) {
            [self.delegate addItemToList:list withItem:self.item withCompletion:^(BOOL succeeded, NSError *error) {
                if(succeeded) {
                    [self performSegueWithIdentifier:@"segueBackToLists" sender:self];
                }
            }];
        }]];
    }
    addItemToListButton.menu = [UIMenu menuWithTitle:@"" children:actions];
    addItemToListButton.showsMenuAsPrimaryAction = YES;
}

@end
