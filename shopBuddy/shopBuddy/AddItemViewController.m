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
@property (weak, nonatomic) IBOutlet UITextField *barcodeField;

@end

@implementation AddItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}
- (IBAction)didTapGetItem:(id)sender {
    [self performSegueWithIdentifier:@"showDetailSegue" sender:self];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
*/
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ItemDetailViewController *detailVC = [segue destinationViewController];
    detailVC.barcode = self.barcodeField.text;
}

@end
