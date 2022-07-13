//
//  APIManager.m
//  shopBuddy
//
//  Created by Rachna Gupta on 7/12/22.
//

#import "APIManager.h"
#import "AFNetworking.h"
#import "Item.h"
static NSString * const baseURLString = @"https://api.barcodelookup.com";
NSString * key;
@implementation APIManager
AFHTTPSessionManager *manager;
+ (instancetype)shared {
    static APIManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (instancetype) init {
    if(self=[super init])
    {
        manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:baseURLString]];
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"Keys" ofType: @"plist"]];
        key = [dict objectForKey: @"api_key"];
    }
    return self;
}

- (void)getItemWithBarcode:(NSString *)barcode completion:(void(^)(Item *item, NSError *error))completion
{

    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"Keys" ofType: @"plist"]];
    NSString *key = [dict objectForKey: @"api_key"];
    //NSString *barcode_call =@"v3/products?barcode=3614272049529&formatted=y&key=";
    NSString *const path = [NSString stringWithFormat:@"v3/products?barcode=%@&formatted=y&key=%@", barcode, key];

    [manager GET:path parameters:nil headers: nil progress:nil success:^(NSURLSessionTask *task, NSDictionary *responseObject)
     {
         // Success
         NSLog(@"Success: %@", responseObject);
        Item *item = [[Item alloc] initWithDictionary:responseObject[@"products"][0]];
        completion(item, nil);
     }failure:^(NSURLSessionDataTask *task, NSError *error)
     {
         // Failure
         NSLog(@"Failure: %@", error);
     }];
    
    
}
- (void)getItem:(void(^)(Item *item, NSError *error))completion
{

    NSString *barcode = @"3614272049529";
    //NSString *barcode_call =@"v3/products?barcode=3614272049529&formatted=y&key=";
    NSString *const path = [NSString stringWithFormat:@"v3/products?barcode=%@&formatted=y&key=%@", barcode, key];

    [manager GET:path parameters:nil headers: nil progress:nil success:^(NSURLSessionTask *task, NSDictionary *responseObject)
     {
         // Success
         NSLog(@"Success: %@", responseObject);
        Item *item = [[Item alloc] initWithDictionary:responseObject[@"products"][0]];
        completion(item, nil);
     }failure:^(NSURLSessionDataTask *task, NSError *error)
     {
         // Failure
         NSLog(@"Failure: %@", error);
     }];
    
    
}
@end
