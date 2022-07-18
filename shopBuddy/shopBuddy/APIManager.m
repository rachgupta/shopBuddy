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
static NSString * const kBarcode_url = @"v3/products?barcode=%@&formatted=y&key=%@";
static NSString * const kSearch_url = @"v3/products?search=%@&formatted=y&key=%@";
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
        key = [[NSDictionary dictionaryWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"Keys" ofType: @"plist"]] objectForKey: @"api_key"];
    }
    return self;
}

- (void)getItemWithBarcode:(NSString *)barcode completion:(void(^)(Item *item, NSError *error))completion
{

    NSString *const path = [NSString stringWithFormat:kBarcode_url, barcode, key];

    [manager GET:path parameters:nil headers: nil progress:nil success:^(NSURLSessionTask *task, NSDictionary *responseObject)
     {
         // Success
        //TODO: Validate server response
        Item *item = [[Item alloc] initWithDictionary:responseObject[@"products"][0]];
        completion(item, nil);
     }failure:^(NSURLSessionDataTask *task, NSError *error)
     {
         // Failure
        //TODO: Failure logic
     }];
    
    
}
- (void)getItemWithSearch:(NSString *)search completion:(void(^)(NSMutableArray<Item*> *items, NSError *error))completion
{

    NSString *const path = [NSString stringWithFormat:kSearch_url, search, key];

    [manager GET:path parameters:nil headers: nil progress:nil success:^(NSURLSessionTask *task, NSDictionary *responseObject)
     {
         // Success
        //TODO: Validate server response
        NSMutableArray *items = [NSMutableArray new];
        for (int i = 0; i < [responseObject[@"products"] count]; i++)
        {
            Item *item = [[Item alloc] initWithDictionary:responseObject[@"products"][i]];
            [items addObject:item];
            
        }
        completion(items, nil);
     }failure:^(NSURLSessionDataTask *task, NSError *error)
     {
         // Failure
        //TODO: Failure logic
     }];
    
    
}
@end
