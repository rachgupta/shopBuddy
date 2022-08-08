//
//  AppDelegate.m
//  shopBuddy
//
//  Created by Rachna Gupta on 7/6/22.
//
\
#import "AppDelegate.h"
#import "Parse/Parse.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(  NSDictionary *)launchOptions {

    ParseClientConfiguration *config = [ParseClientConfiguration  configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {

        configuration.applicationId = @"OgUfVce3Fk0NRDd46nj9CXz4OY1dK2Cbu9tXRJkF"; // <- UPDATE
        configuration.clientKey = @"76h1uwTJOCqn7pNG1m0d15Ev3ByNb9b43Ua6nOEY"; // <- UPDATE
        configuration.server = @"https://parseapi.back4app.com";
    }];

    [Parse initializeWithConfiguration:config];
    if (@available(iOS 15.0, *)) {
        UINavigationBarAppearance *navBarAppearance = [[UINavigationBarAppearance alloc] init];
        navBarAppearance.backgroundColor = [UIColor colorWithRed: 0.05 green: 0.04 blue: 0.37 alpha: 1.00];
        navBarAppearance.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
        //[navBarAppearance configureWithOpaqueBackground];
        [UINavigationBar appearance].standardAppearance = navBarAppearance;
        [UINavigationBar appearance].scrollEdgeAppearance = navBarAppearance;
    }

    return YES;
}

#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
