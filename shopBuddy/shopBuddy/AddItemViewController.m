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
#import <AVFoundation/AVFoundation.h>
#import "ScanBarcodeViewController.h"

@interface AddItemViewController ()
@property (weak, nonatomic) IBOutlet UITextField *barcodeField;

@end

@implementation AddItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}
- (IBAction)didTapScanBarcode:(id)sender {
    [self performSegueWithIdentifier:@"showBarcodeSegue" sender:self];
}
- (IBAction)didTapGetItem:(id)sender {
    [self performSegueWithIdentifier:@"showDetailSegue" sender:self];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqual:@"showDetailSegue"])
    {
        ItemDetailViewController *detailVC = [segue destinationViewController];
        detailVC.barcode = self.barcodeField.text;
    }
    else if([segue.identifier isEqual:@"showBarcodeSegue"])
    {
        ScanBarcodeViewController *barcodeVC = [segue destinationViewController];
    }
}

@end
