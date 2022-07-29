//
//  GlobalManager.m
//  shopBuddy
//
//  Created by Rachna Gupta on 7/27/22.
//

#import "GlobalManager.h"
#import "Item.h"

@interface GlobalManager ()
{
    NSString *priceKey;
}
@property (atomic, strong) NSMutableDictionary<NSString *, NSString *> *itemJobIdMap;
@property (atomic, strong) NSMutableArray<NSString *> *outstandingJobs; // Job sync in progress
@property (atomic, strong) NSMutableDictionary<NSString *, NSDictionary *> *completeJobs;

@end
@implementation GlobalManager


static NSString * const kJob_URL = @"https://api.priceapi.com/v2/jobs?token=%@";
static NSString * const kJobID_URL = @"https://api.priceapi.com/v2/jobs/%@?token=%@";
static NSString * const kJobDownload_URL = @"https://api.priceapi.com/v2/jobs/%@/download?token=%@";

+ (id)sharedManager {
    static GlobalManager *sharedGlobalManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedGlobalManager = [[self alloc] init];
    });
    return sharedGlobalManager;
}
//TODO: Parse
- (id)init {
    if (self = [super init]) {
        self.itemJobIdMap = [NSMutableDictionary dictionary];
        self.outstandingJobs = [NSMutableArray array];
        self.completeJobs = [NSMutableDictionary dictionary];
        priceKey = [[NSDictionary dictionaryWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"Keys" ofType: @"plist"]] objectForKey: @"price_api_key"];
        
    }
    return self;
}

- (void)fetchPricesWithItem:(Item *)item fromStore: (NSString *)store completion:(void(^)(NSDictionary *prices, BOOL success))completion {
    //TODO: Parse Dictionary and return Array of NSObject Price
    NSString *const jobId = self.itemJobIdMap[item.name];
    if (jobId == nil) {
        [self _submitJob:item.name withStore:store withCompletion:^(NSString *job_id, NSError *error) {
            if(!error) {
                self.itemJobIdMap[item.name] = job_id;
                [self _checkJobStatus:job_id withCompletion:completion];
            }
        }];
    } else {
        [self _checkJobStatus:jobId withCompletion:completion];
    }
}

- (void)_checkJobStatus: (NSString *)job_id withCompletion:(void(^)(NSDictionary *prices, BOOL success))completion {
    if (self.completeJobs[job_id]!=nil) {
        completion(self.completeJobs[job_id],YES);
        //TODO: check if stale
        return;
    }

    if ([self.outstandingJobs containsObject:job_id]) {
        // Time window passed but last sync is not ready
        __weak __typeof(self) weakSelf = self;
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        const dispatch_time_t timeoutTime = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
        dispatch_after(timeoutTime, queue, ^{
            [weakSelf _checkJobStatus:job_id withCompletion:completion];
        });
        return;
    }

    // Either is a new job or is retry for an incomplete job
    __weak __typeof(self) weakSelf = self;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [self.outstandingJobs addObject:job_id];
        [weakSelf _requestJobStatus:job_id withCompletion:^(BOOL jobIsFinished, NSError *error) {
            [weakSelf _jobStatusCallback:job_id finished:jobIsFinished withCompletion:^(NSDictionary *prices, BOOL success) {
                completion(prices,success);
            }];
        }];
    });
}

- (void)_jobStatusCallback:(NSString *)jobId finished: (BOOL)finished withCompletion:(void(^)(NSDictionary *prices, BOOL success))completion {
    if (finished) {
        __weak __typeof(self) weakSelf = self;
        [self _downloadJobResults:jobId withCompletion:^(NSDictionary *results, NSError *error) {
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf != nil) {
                if(!error) {
                    self.completeJobs[jobId] = results;
                    [self.outstandingJobs removeObject:jobId];
                    completion(results,YES);
                }
            }
        }];
    } else {
        [self.outstandingJobs removeObject:jobId];
        [self _retryIfNeeded:jobId withCompletion:completion];
    }
}
- (void)_retryIfNeeded: (NSString *)jobID withCompletion:(void(^)(NSDictionary *prices, BOOL success))completion{
    [self _checkJobStatus: jobID withCompletion:completion];
}

- (void) _submitJob: (NSString *)term withStore: (NSString *) store withCompletion: (void(^)(NSString *job_id, NSError *error))completion {
    NSDictionary *const headers = @{ @"Accept": @"application/json", @"Content-Type": @"application/json" };
    NSDictionary *const parameters = @{ @"source": store, @"country": @"us", @"topic": @"product_and_offers", @"key": @"term", @"values": term, @"token": priceKey};
    NSData *const postData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:kJob_URL,priceKey]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:headers];
    [request setHTTPBody:postData];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            completion(nil,error);
        } else {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
            if ([httpResponse statusCode]==200) {
                NSError *er = nil;
                NSDictionary *const dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&er];
                NSString *const job_id = dict[@"job_id"];
                completion(job_id,nil);
            }
        }
    }];
    [dataTask resume];
}


- (void) _requestJobStatus: (NSString *)jobID withCompletion:(void(^)(BOOL jobIsFinished, NSError *error))completion {
    NSDictionary *const headers = @{ @"Accept": @"application/json" };
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:kJobID_URL,jobID,priceKey]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
    [request setHTTPMethod:@"GET"];
    [request setAllHTTPHeaderFields:headers];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            completion(nil, error);
        } else {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
            if([httpResponse statusCode]==200) {
                NSError *er = nil;
                NSDictionary *const dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&er];
                const BOOL success = [dict[@"status"] isEqual:@"finished"];
                completion(success, nil);
            }
            
        }
    }];
    [dataTask resume];
}
- (void) _downloadJobResults: (NSString *)jobID withCompletion:(void(^)(NSDictionary *results, NSError *error))completion {
    NSDictionary *const headers = @{ @"Accept": @"application/json" };
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:kJobDownload_URL,jobID,priceKey]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
    [request setHTTPMethod:@"GET"];
    [request setAllHTTPHeaderFields:headers];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            completion(nil,error);
        } else {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
            if([httpResponse statusCode]==200) {
                NSError *er = nil;
                NSDictionary *const dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&er];
                NSDictionary *const results = dict[@"results"];
                completion(results,nil);
            }
        }
    }];
    [dataTask resume];
}


@end
