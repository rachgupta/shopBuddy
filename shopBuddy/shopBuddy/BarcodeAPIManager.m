//
//  APIManager.m
//  shopBuddy
//
//  Created by Rachna Gupta on 7/12/22.
//

#import "BarcodeAPIManager.h"
#import "AFNetworking.h"
#import "Item.h"
#import "Item+Persistent.h"

static NSString * const baseURLString = @"https://api.barcodelookup.com";
static NSString * const kBarcode_url = @"v3/products?barcode=%@&formatted=y&key=%@";
static NSString * const kSearch_url = @"v3/products?search=%@&formatted=y&key=%@&metadata=y&cursor=y";
static NSString * const kSearch_cursor_url = @"v3/products?search=%@&formatted=y&key=%@&metadata=y&cursor=%@";
NSString * key;
@implementation BarcodeAPIManager
AFHTTPSessionManager *manager;
+ (instancetype)shared {
    static BarcodeAPIManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [self new];
    });
    return sharedManager;
}

- (instancetype) init {
    if(self=[super init])
    {
        manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:baseURLString]];
        key = [[NSDictionary dictionaryWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"Keys" ofType: @"plist"]] objectForKey: @"barcode_api_key"];
    }
    return self;
}

- (void)getItemWithBarcode:(NSString *)barcode completion:(void(^)(Item *item, NSError *error))completion
{

    NSString *const path = [NSString stringWithFormat:kBarcode_url, barcode, key];

    [manager GET:path parameters:nil headers: nil progress:nil success:^(NSURLSessionTask *task, NSDictionary *responseObject)
     {
        Item *item = [Item createItemWithDictionary:responseObject[@"products"][0]];
        completion(item, nil);
     }failure:^(NSURLSessionDataTask *task, NSError *error)
     {
        completion(nil,error);
     }];
    
    
}
- (void)searchItemsWithQuery:(NSString *)search completion:(void(^)(NSMutableArray<Item*> *items, NSError *error))completion
{
    NSString *const path = [NSString stringWithFormat:kSearch_url, search, key];
    __weak __typeof__(self) weakSelf = self;
    __block NSMutableArray *all_items = [NSMutableArray new];
    [weakSelf _getSearchResultsWithPath:path completion:^(NSMutableArray<Item *> *items, NSString *cursor, NSError *error) {
        if(items) {
            [all_items addObjectsFromArray:items];
        }
        if(cursor) {
            NSString *const cursor_path = [NSString stringWithFormat:kSearch_cursor_url, search, key,cursor];
            [weakSelf _getSearchResultsWithPath:cursor_path completion:^(NSMutableArray<Item *> *items, NSString *cursor, NSError *error) {
                [all_items addObjectsFromArray:items];
                completion(all_items,nil);
            }];
        }
    }];
}

- (void) _getSearchResultsWithPath:(NSString *)path completion:(void(^)(NSMutableArray<Item*> *items, NSString *cursor, NSError *error))completion {
    [manager GET:path parameters:nil headers: nil progress:nil success:^(NSURLSessionTask *task, NSDictionary *responseObject)
     {
        NSMutableArray *items = [NSMutableArray new];
        for (int i = 0; i < [responseObject[@"products"] count]; i++)
        {
            Item *item = [Item createItemWithDictionary:responseObject[@"products"][i]];
            NSArray *categories = [responseObject[@"products"][i][@"category"] componentsSeparatedByString:@" > "];
            item.category = categories[0];
            [items addObject:item];
            
        }
        if(responseObject[@"metadata"] [@"next_cursor"]) {
            completion(items,responseObject[@"metadata"] [@"next_cursor"],nil);
        }
        else {
            completion(items,nil,nil);
        }
     }failure:^(NSURLSessionDataTask *task, NSError *error)
     {
        completion(nil,nil,error);
     }];
    
}
@end
