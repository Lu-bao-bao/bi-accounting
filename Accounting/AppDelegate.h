//
//  AppDelegate.h
//  Accounting
//
//  Created by AmeRin on 9/10/2017.
//  Copyright © 2017 RM studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <WatchConnectivity/WatchConnectivity.h>

#define APP_GROUP   @"group.org.rm-s.accounting"
#define APP_ID      @"1331031395"

@interface PersistentContainer: NSPersistentContainer
+ (NSURL *)defaultDirectoryURL;
@end

@interface AppDelegate : UIResponder <UIApplicationDelegate, WCSessionDelegate>
@property (strong, nonatomic) UIWindow *window;
@property (readonly, strong) PersistentContainer *persistentContainer;

- (void)saveContext;
+ (void)updateApplicationContextForCategory: (NSManagedObjectContext *)context;
@end
