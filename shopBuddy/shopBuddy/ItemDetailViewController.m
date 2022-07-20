//
//  ItemDetailViewController.m
//  shopBuddy
//
//  Created by Rachna Gupta on 7/11/22.
//

#import "ItemDetailViewController.h"
#import "Item.h"
#import "UIImageView+AFNetworking.h"
#import "APIManager.h"
#import "ShoppingList.h"

@interface ItemDetailViewController ()
{
    NSArray<ShoppingList*> *lists;
}
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *brandLabel;
@property (weak, nonatomic) IBOutlet UIImageView *itemImage;
@property (weak, nonatomic) IBOutlet UITextView *descriptionView;
@property (weak, nonatomic) IBOutlet UIButton *addItemToListButton;


@end

@implementation ItemDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.descriptionView.scrollEnabled=YES;
    if (self.item != nil) {
        [self _populateView];
    } else {
        [self _callAPI];
    }
    [self _fetchLists];
}

- (void)_callAPI {
    [[APIManager shared] getItemWithBarcode:self.barcode completion:^(Item *item, NSError *error) {
        if (item) {
            self.item = item;
            [self _populateView];
        } else {
            //TODO: Failure logic
        }
    }];
}

- (void)_populateView {
    //TODO: add Show More button and shortened description
    self.titleLabel.text = self.item.name;
    self.brandLabel.text = self.item.brand;
    self.descriptionView.text = self.item.item_description;
    NSString *const URLString = self.item.images[0];
    NSURL *const url = [NSURL URLWithString:URLString];
    [self.itemImage setImageWithURL:url];
}

- (void)_fetchLists {
    PFQuery *query = [PFQuery queryWithClassName:@"ShoppingList"];
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"user"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *fetched_lists, NSError *error) {
        if (fetched_lists != nil) {
            self->lists = fetched_lists;
            [self _makeMenu];
        }
    }];
}
- (void) _makeMenu {
    NSMutableArray* actions = [[NSMutableArray alloc] init];
    for (ShoppingList *list in lists) {
        NSString *const actionTitle = [NSString stringWithFormat:@"Add Item to '%@' list", list.store_name];
        [actions addObject:[UIAction actionWithTitle:actionTitle image:nil identifier:nil handler:^(__kindof UIAction* _Nonnull action) {
                    self.item.list = list;
                    [list addItemToList:self.item];
                    [self performSegueWithIdentifier:@"segueBackToLists" sender:self];
                }]];
    }
    UIMenu *menu = [UIMenu menuWithTitle:@"" children:actions];
    _addItemToListButton.menu = menu;
    _addItemToListButton.showsMenuAsPrimaryAction = YES;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
