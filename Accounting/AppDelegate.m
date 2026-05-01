//
//  AppDelegate.m
//  Accounting
//
//  Created by AmeRin on 9/10/2017.
//  Copyright © 2017 RM studio. All rights reserved.
//

#import "AppDelegate.h"
#import <WatchConnectivity/WatchConnectivity.h>
#import "CategoryModel.h"
#import "AccountingModel.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // Load persistent container
    [self persistentContainer];

    // Load default data?
    [self loadDefaultCategoryData];

    // WC Session start
    if( [WCSession isSupported] ) {
        WCSession *session = [WCSession defaultSession];
        session.delegate = self;
        [session activateSession];
    }

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}


#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (PersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[PersistentContainer alloc] initWithName:@"Model"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                    */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}

- (void)loadDefaultCategoryData {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if(![userDefaults boolForKey:@"firstBoot"]) {
        [userDefaults setBool:YES forKey:@"firstBoot"];
        [userDefaults synchronize];
        
        // read default data from plist file
        NSString *defaultCategoryPath = [[NSBundle mainBundle] pathForResource:@"DefaultCategory" ofType:@"plist"];
        NSMutableDictionary *defaultCategoryData = [[NSMutableDictionary alloc] initWithContentsOfFile:defaultCategoryPath];
        
        for( id category in defaultCategoryData ) {
            
            @try {
                NSLog(@"%@", [defaultCategoryData objectForKey:category]);
                
                NSDictionary *categoryDict = [defaultCategoryData objectForKey:category];
                [CategoryModel appendCategory:self.persistentContainer.viewContext
                                         name:[categoryDict objectForKey:@"name"]
                                         icon:[categoryDict objectForKey:@"icon"]
                                        alias:@""
                                         type:[categoryDict objectForKey:@"type"]
                                     sequence:(NSInteger)[categoryDict objectForKey:@"sequence"] ];
            }
            @catch (NSException *exception) {
                // Print exception information
                NSLog( @"NSException caught" );
                NSLog( @"Name: %@", exception.name);
                NSLog( @"Reason: %@", exception.reason );
            }
            
        }
    }
}

#pragma mark - Watch Connectivity Delegate
- (void)session:(nonnull WCSession *)session activationDidCompleteWithState:(WCSessionActivationState)activationState error:(nullable NSError *)error {
    [AppDelegate updateApplicationContextForCategory: self.persistentContainer.viewContext];
}
- (void)sessionDidBecomeInactive:(nonnull WCSession *)session {}
- (void)sessionDidDeactivate:(nonnull WCSession *)session {}

- (void)session:(nonnull WCSession *)session didReceiveMessage:(nonnull NSDictionary<NSString *,id> *)message
   replyHandler:(nonnull void (^)(NSDictionary<NSString *,id> * __nonnull))replyHandler {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"Received message: %@", message);
        if( [message[@"Action"] isEqualToString: @"create_item"] ) {
            NSDecimalNumber *amount = [NSDecimalNumber decimalNumberWithDecimal:[message[@"Amount"] decimalValue]];
            NSString *category = message[@"Category"];
            [CategoryModel transAmountViaCategoryType:&amount categoryName:category context:self.persistentContainer.viewContext];
            [AccountingModel createAccounting:self.persistentContainer.viewContext
                                       amount:amount category:category tags:@"" comment:message[@"Category"] createTime: [NSDate date]
                               successHandler:^{
                                   // reply success message -> watch
                                   replyHandler(@{@"Action": @"create_item", @"Result": @"success"});
                               } errorHandler:^(NSError *error) {
                                   // reply fail message -> watch
                                   replyHandler(@{@"Action": @"create_item", @"Result": @"fail"});
                               }];
        }
    });
}

#pragma mark - Update application context for category
+ (void)updateApplicationContextForCategory: (NSManagedObjectContext *)context {
    // refresh application context.
    if([WCSession isSupported]) {
        WCSession *session = [WCSession defaultSession];
        
        // TO-DO
        if( session.activationState == WCSessionActivationStateActivated ) {
            NSMutableArray *categories = [[NSMutableArray alloc] init];
            NSMutableArray *icons = [[NSMutableArray alloc] init];
            for( Category *category in [CategoryModel getCategories:context] ) {
                [categories addObject:category.name];
                [icons addObject:(category.icon == nil)?@"":category.icon];
            }
            NSLog(@"categories name: %@", categories);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *err;
                if (![session updateApplicationContext:@{@"Categories": categories, @"Icons": icons} error:&err]) {
                    NSLog(@"updateApplicationContext failed with error %@", err);
                }
            });
            
            NSLog(@"WCSession is activated.");
        }
    }
}

@end


@implementation PersistentContainer
+ (NSURL *)defaultDirectoryURL { return [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:APP_GROUP]; }
@end
