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
#import "ShoppingList+Persistent.h"

@interface ItemDetailViewController ()
{
    NSArray<ShoppingList*> *lists;
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
    if (self.item != nil) {
        [self _populateView];
    } else {
        [self _callAPI];
    }
    [ShoppingList fetchListsByUser:[PFUser currentUser] withCompletion:^(NSArray *lists, NSError *error) {
        self->lists = lists;
        [self _makeMenu];
    }];
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
    titleLabel.text = self.item.name;
    brandLabel.text = self.item.brand;
    descriptionView.text = self.item.item_description;
    NSString *const URLString = self.item.images[0];
    NSURL *const url = [NSURL URLWithString:URLString];
    [itemImage setImageWithURL:url];
}

- (void) _makeMenu {
    NSMutableArray* actions = [[NSMutableArray alloc] init];
    for (ShoppingList *list in lists) {
        NSString *const actionTitle = [NSString stringWithFormat:@"Add Item to '%@' list", list.store_name];
        [actions addObject:[UIAction actionWithTitle:actionTitle image:nil identifier:nil handler:^(__kindof UIAction* _Nonnull action) {
            [list addItemToList:self.item withList:list  withCompletion:^(BOOL succeeded, NSError *error) {
                        if(error){
                             NSLog(@"Error adding item to list: %@", error.localizedDescription);
                        }
                        else{
                            NSLog(@"Successfully added item");
                        }
                    }];
                    [self performSegueWithIdentifier:@"segueBackToLists" sender:self];
                }]];
    }
    UIMenu *menu = [UIMenu menuWithTitle:@"" children:actions];
    addItemToListButton.menu = menu;
    addItemToListButton.showsMenuAsPrimaryAction = YES;
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
