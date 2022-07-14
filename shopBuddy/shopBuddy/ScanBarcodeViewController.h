//
//  ScanBarcodeViewController.h
//  shopBuddy
//
//  Created by Rachna Gupta on 7/14/22.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ScanBarcodeViewController : UIViewController <AVCaptureMetadataOutputObjectsDelegate>
@property (nonatomic) BOOL isScanning;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;


-(BOOL)startScanning;
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection;
-(void)updateWithBarcode:(NSString *)barcode;
-(void)stopScanning;

@end

NS_ASSUME_NONNULL_END
