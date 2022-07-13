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

@interface AddItemViewController ()

@end

@implementation AddItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[APIManager shared] getItem:^(NSDictionary *itemDetails, NSError *error) {
        NSLog(@"😎😎😎 Successfully loaded itemDetails");
        if (itemDetails) {
            NSLog(@"😎😎😎 Successfully loaded itemDetails");
            self.item = [[Item alloc] initWithDictionary:itemDetails[@"products"][0]];
            
        }
        else {
            NSLog(@"😫😫😫 Error getting item details: %@", error.localizedDescription);
        }
    }];
    // Do any additional setup after loading the view.
}
- (IBAction)didTapGetItem:(id)sender {
    [[APIManager shared] getItem:^(NSDictionary *itemDetails, NSError *error) {
        NSLog(@"😎😎😎 Successfully loaded itemDetails");
        if (itemDetails) {
            NSLog(@"😎😎😎 Successfully loaded itemDetails");
            self.item = [[Item alloc] initWithDictionary:itemDetails[@"products"][0]];
            
        }
        else {
            NSLog(@"😫😫😫 Error getting item details: %@", error.localizedDescription);
        }
    }];
    [self performSegueWithIdentifier:@"showDetailSegue" sender:self];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
*/
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ItemDetailViewController *detailVC = [segue destinationViewController];
    detailVC.item = self.item;
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
