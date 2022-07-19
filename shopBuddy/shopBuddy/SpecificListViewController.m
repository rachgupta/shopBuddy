//
//  ShoppingListViewController.m
//  shopBuddy
//
//  Created by Rachna Gupta on 7/6/22.
//

#import "SpecificListViewController.h"

@interface SpecificListViewController ()
@property (weak, nonatomic) IBOutlet UILabel *list_label;

@end

@implementation SpecificListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _list_label.text = [NSString stringWithFormat:@"%@ Shopping List", self.list.store_name];
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
