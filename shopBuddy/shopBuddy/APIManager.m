//
//  APIManager.m
//  shopBuddy
//
//  Created by Rachna Gupta on 7/12/22.
//

#import "APIManager.h"
#import "AFNetworking.h"
static NSString * const baseURLString = @"https://api.barcodelookup.com";

@implementation APIManager
+ (instancetype)shared {
    static APIManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (instancetype) init {
    self = [super init];
    self.manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:baseURLString]];
    return self;
}

- (void)getItem:(void(^)(NSArray *itemDetails, NSError *error))completion
{

    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"Keys" ofType: @"plist"]];
    NSString *key = [dict objectForKey: @"api_key"];
    NSString *barcode_call =@"v3/products?barcode=3614272049529&formatted=y&key";
    NSString *path = [NSString stringWithFormat:@"%@%@", barcode_call, key];

    /*
    [self.manager GET:path parameters:nil success:^(NSURLSessionDataTask *task, NSArray *itemDetails)
     {
         // Success
         NSLog(@"Success: %@", itemDetails);
     }failure:^(NSURLSessionDataTask *task, NSError *error)
     {
         // Failure
         NSLog(@"Failure: %@", error);
     }];
     */
    
    
}
@end
