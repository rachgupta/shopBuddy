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
    self.manager = [AFHTTPSessionManager manager];
    return self;
}

- (void)getItem:(void(^)(NSArray *itemDetails, NSError *error))completion
{

    NSString *path = [[NSBundle mainBundle] pathForResource: @"Keys" ofType: @"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: path];
    NSString *key = [dict objectForKey: @"api_key"];
    
    
}
@end
