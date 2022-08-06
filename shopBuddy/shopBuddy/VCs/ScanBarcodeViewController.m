//
//  ScanBarcodeViewController.m
//  shopBuddy
//
//  Created by Rachna Gupta on 7/14/22.
//

#import "ScanBarcodeViewController.h"
#import "AVFoundation/AVFoundation.h"
#import "ItemDetailViewController.h"

@interface ScanBarcodeViewController () {
    BOOL isScanning;
    AVCaptureSession *captureSession;
    AVCaptureVideoPreviewLayer *videoPreviewLayer;
    NSString *barcode;
    __weak IBOutlet UIView *preview;
    __weak IBOutlet UIBarButtonItem *scanButton;
    
}

@end
@implementation ScanBarcodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    isScanning = NO;
    captureSession = nil;
    
}

//changes the boolean property if the stop/start button is pressed
- (IBAction)startStopScanning:(id)sender {
    if (!isScanning) {
        if ([self _startScanning]) {
            [scanButton setTitle:@"Stop Scanning"];
        }
    } else {
        [self _stopScanning];
        [scanButton setTitle:@"Start Scanning"];
    }
    isScanning = !isScanning;
}

//starts scanning for barcodes (metadata objects) and runs the capturesession
- (BOOL)_startScanning {
    NSError *error;
 
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if (!input) {
        return NO;
    }
    captureSession = [AVCaptureSession new];
    [captureSession addInput:input];
    AVCaptureMetadataOutput *captureMetadataOutput = [AVCaptureMetadataOutput new];
    [captureSession addOutput:captureMetadataOutput];
    const dispatch_queue_t dispatchQueue = dispatch_queue_create("myQueue", NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeEAN13Code]];
    videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:captureSession];
    [videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [videoPreviewLayer setFrame:preview.layer.bounds];
    [preview.layer addSublayer:videoPreviewLayer];
    [captureSession startRunning];
    return YES;
}

//updates the lookup button and the _barcode variable to reflect the new barcode
-(void)_updateWithBarcode:(NSString *)givenBarcode {
    barcode = givenBarcode;
    [self performSegueWithIdentifier:@"showItemDetailView" sender:self];
    //TODO: Validate Barcode
}

//this method stops the capture session
-(void)_stopScanning{
    [captureSession stopRunning];
    captureSession = nil;
    [videoPreviewLayer removeFromSuperlayer];
}

//sends barcode info to detail view
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqual:@"showItemDetailView"]) {
        ItemDetailViewController *detailVC = [segue destinationViewController];
        detailVC.barcode = barcode;
    }
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate

//run when an object is captured (a barcode is scanned)
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if ([metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *const metadataObj = [metadataObjects objectAtIndex:0];
        [self performSelectorOnMainThread:@selector(_stopScanning) withObject:nil waitUntilDone:NO];
        [scanButton performSelectorOnMainThread:@selector(setTitle:) withObject:@"Start Scanning" waitUntilDone:NO];
        [self performSelectorOnMainThread:@selector(_updateWithBarcode:) withObject:[metadataObj stringValue] waitUntilDone:NO];
        isScanning = NO;
    }
}

@end
