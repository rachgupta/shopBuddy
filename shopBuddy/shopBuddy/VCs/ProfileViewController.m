//
//  ProfileViewController.m
//  shopBuddy
//
//  Created by Rachna Gupta on 7/7/22.
//

#import "ProfileViewController.h"
#import "Parse/Parse.h"

@interface ProfileViewController ()
@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;
@property (weak, nonatomic) IBOutlet UILabel *budgetLabel;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *username = PFUser.currentUser.username;
    self.welcomeLabel.text = [NSString stringWithFormat:@"Welcome, %@",username];
    self.budgetLabel.text = [NSString stringWithFormat:@"Budget for this month: $ %.2f",[[PFUser currentUser][@"budget"] doubleValue]];
    // Do any additional setup after loading the view.
}

- (void)_showInputAlert {
  UIAlertController *alertVC=[UIAlertController alertControllerWithTitle:@"Set your new budget" message:@"Please input the new budget for the month" preferredStyle:UIAlertControllerStyleAlert];
    [alertVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
      {
        textField.placeholder=@"ex. 20.00";
        textField.textColor=[UIColor redColor];
        textField.clearButtonMode=UITextFieldViewModeWhileEditing;
      }
    }];
    __weak __typeof__(self) weakSelf = self;
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Submit" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        PFUser *current_user = [PFUser currentUser];
        current_user[@"budget"] = @([alertVC.textFields[0].text doubleValue]);
        [current_user saveInBackground];
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if(strongSelf) {
            strongSelf.budgetLabel.text = [NSString stringWithFormat:@"Budget for this month: $ %.2f",[[PFUser currentUser][@"budget"] doubleValue]];
        }
    }];
    [alertVC addAction:action];
    [self presentViewController:alertVC animated:true completion:nil];
}

- (IBAction)didTapSetBudget:(id)sender {
    [self _showInputAlert];
}
- (IBAction)didTapLogout:(id)sender {
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {nil;}];
    [self dismissViewControllerAnimated:YES completion:nil];
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
