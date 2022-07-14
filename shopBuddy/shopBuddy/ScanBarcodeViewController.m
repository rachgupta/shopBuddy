//
//  ScanBarcodeViewController.m
//  shopBuddy
//
//  Created by Rachna Gupta on 7/14/22.
//

#import "ScanBarcodeViewController.h"
#import "AVFoundation/AVFoundation.h"
#import "ItemDetailViewController.h"

@interface ScanBarcodeViewController ()
@property (weak, nonatomic) IBOutlet UIView *preview;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *scanButton;
@property (weak, nonatomic) IBOutlet UIButton *lookupButton;
@property NSString *barcode;

@end
@implementation ScanBarcodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _isScanning = NO;
    _captureSession = nil;
    [_lookupButton setTitle:@" " forState:UIControlStateNormal];
    
}
//changes the boolean property if the stop/start button is pressed
- (IBAction)startStopScanning:(id)sender {
    if (!_isScanning) {
            if ([self startScanning]) {
                [_scanButton setTitle:@"Stop Scanning"];
            }
        }
        else{
            [self stopScanning];
            [_scanButton setTitle:@"Start Scanning"];
        }
        
        _isScanning = !_isScanning;
    }
//starts scanning for barcodes (metadata objects) and runs the capturesession
- (BOOL)startScanning {
    NSError *error;
 
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
     
        if (!input) {
            NSLog(@"%@", [error localizedDescription]);
            return NO;
        }
    _captureSession = [[AVCaptureSession alloc] init];
        [_captureSession addInput:input];
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
        [_captureSession addOutput:captureMetadataOutput];
    dispatch_queue_t dispatchQueue;
        dispatchQueue = dispatch_queue_create("myQueue", NULL);
        [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
        [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeEAN13Code]];
        _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
        [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        [_videoPreviewLayer setFrame:_preview.layer.bounds];
        [_preview.layer addSublayer:_videoPreviewLayer];
    [_captureSession startRunning];
    return YES;
    
}
//run when an object is captured (a barcode is scanned)
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
            [self performSelectorOnMainThread:@selector(stopScanning) withObject:nil waitUntilDone:NO];
        [_scanButton performSelectorOnMainThread:@selector(setTitle:) withObject:@"Start Scanning" waitUntilDone:NO];
        [self performSelectorOnMainThread:@selector(updateWithBarcode:) withObject:[metadataObj stringValue] waitUntilDone:NO];
                _isScanning = NO;
        }
    }

//updates the lookup button and the _barcode variable to reflect the new barcode
-(void)updateWithBarcode:(NSString *)barcode {
    [_lookupButton setTitle:[NSString stringWithFormat:@"Lookup Item with Barcode %@",barcode] forState:UIControlStateNormal];
    _barcode = barcode;
}
//this method stops the capture session
-(void)stopScanning{
    [_captureSession stopRunning];
    _captureSession = nil;
    [_videoPreviewLayer removeFromSuperlayer];
}

//triggers segue to detail view
- (IBAction)didTapLookup:(id)sender {
    [self performSegueWithIdentifier:@"showItemDetailView" sender:self];

}

//sends barcode info to detail view
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqual:@"showItemDetailView"])
    {
        ItemDetailViewController *detailVC = [segue destinationViewController];
        detailVC.barcode = _barcode;
    }
}

@end
