//
//  AddItemViewController.m
//  shopBuddy
//
//  Created by Rachna Gupta on 7/12/22.
//

#import "AddItemViewController.h"
#import "APIManager.h"
#import "Item.h"

@interface AddItemViewController ()

@end

@implementation AddItemViewController
- (IBAction)didTapTestAPI:(id)sender {
    [[APIManager shared] getItem:^(NSDictionary *itemDetails, NSError *error) {
        NSLog(@"😎😎😎 Successfully loaded itemDetails");
        if (itemDetails) {
            NSLog(@"😎😎😎 Successfully loaded itemDetails");
            NSDictionary *itemDict = itemDetails[@"products"][0];
            NSString *title = itemDict[@"title"];
            self.item = [[Item alloc] initWithDictionary:itemDetails[@"products"][0]];
            
        }
        else {
            NSLog(@"😫😫😫 Error getting item details: %@", error.localizedDescription);
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
