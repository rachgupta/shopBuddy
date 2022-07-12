//
//  AddItemViewController.m
//  shopBuddy
//
//  Created by Rachna Gupta on 7/12/22.
//

#import "AddItemViewController.h"
#import "APIManager.h"

@interface AddItemViewController ()

@end

@implementation AddItemViewController
- (IBAction)didTapTestAPI:(id)sender {
    [[APIManager shared] getItem:^(NSDictionary *itemDetails, NSError *error) {
        if (itemDetails) {
            NSLog(@"😎😎😎 Successfully loaded itemDetails");
        } else {
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
