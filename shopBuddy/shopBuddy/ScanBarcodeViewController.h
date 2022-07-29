//
//  ScanBarcodeViewController.h
//  shopBuddy
//
//  Created by Rachna Gupta on 7/14/22.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "ShoppingListManagerViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ScanBarcodeViewController : UIViewController <AVCaptureMetadataOutputObjectsDelegate>
@property (strong, nonatomic) NSArray<ShoppingList *> *lists;
@property (nonatomic, weak) id<ShoppingListDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
