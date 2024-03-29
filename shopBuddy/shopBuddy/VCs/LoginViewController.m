//
//  LoginViewController.m
//  shopBuddy
//
//  Created by Rachna Gupta on 7/6/22.
//

#import "LoginViewController.h"
#import "Parse/Parse.h"
#import "ShoppingList.h"
#import "ShoppingList+Persistent.h"
#import "Cart+Persistent.h"
#import "AppState.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)registerUser:(id)sender {
    [self checkFields];
    PFUser *newUser = [PFUser user];
        
        // set user properties
        newUser.username = self.usernameField.text;
        newUser.password = self.passwordField.text;
        // call sign up function on the object
        [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
            newUser[@"budget"] = [NSNumber numberWithDouble:50.00];
            [newUser saveInBackground];
            if (!error) {
                NSLog(@"User registered successfully");
                __weak __typeof__(self) weakSelf = self;
                [ShoppingList createEmptyList: @"Unspecified" withCompletion:^(ShoppingList *shoppingList,NSError *error) {
                    if(!error) {
                        [Cart createEmptyCart:^(Cart * _Nonnull new_cart, NSError * _Nonnull error) {
                            if(!error) {
                                AppState *state = [AppState sharedManager];
                                state.cart = new_cart;
                                state.trips = [NSArray new];
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [weakSelf performSegueWithIdentifier:@"loginSegue" sender:nil];
                                });
                            }
                        }];
                    }
                }];
                // manually segue to logged in view
            }
        }];
}
- (IBAction)loginUser:(id)sender {
    [self checkFields];
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;
        
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser * user, NSError *  error) {
        if (error != nil) {
            NSLog(@"User log in failed: %@", error.localizedDescription);
        } else {
            NSLog(@"User logged in successfully");
            [self performSegueWithIdentifier:@"loginSegue" sender:nil];
        }
    }];
}
- (void) checkFields
{
    if([self.usernameField.text length] == 0)
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No Username" message:@"Please input a Username" preferredStyle:(UIAlertControllerStyleAlert)];
        // create an OK action
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){}];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:^{}];
    }
    if([self.passwordField.text length] == 0)
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No Password" message:@"Please input a Password" preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){}];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:^{}];
    }
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
