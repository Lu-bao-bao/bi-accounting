//
//  BaseModel.m
//  Accounting
//
//  Created by AmeRin on 26/10/2017.
//  Copyright © 2017 RM studio. All rights reserved.
//

#import "BaseModel.h"
#import <CoreData/CoreData.h>

#define APP_GROUP @"group.org.rm-s.accounting"

@implementation BaseModel

+ (NSManagedObjectContext *)setupCoreDataStackWithStoreNamed:(NSString *)storeNamed
{
    NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:APP_GROUP];
    NSURL *storeURL = [containerURL URLByAppendingPathComponent: [[NSString alloc] initWithFormat:@"%@.sqlite", storeNamed]];
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:storeNamed withExtension:@"momd"];
    
    NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    
    [coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:nil];
    
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType]; /* NSPrivateQueueConcurrencyType? */
    [context performBlockAndWait:^{
        [context setPersistentStoreCoordinator:coordinator];
    }];
    
    return context;
}

+ (NSFetchRequest *)getBaseFetchRequest:(NSManagedObjectContext*)context entityForName:(NSString*)entityName {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    NSSortDescriptor *sortSequence = [[NSSortDescriptor alloc] initWithKey:@"sequence" ascending:true];
    NSSortDescriptor *sortName = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:true];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortSequence, sortName, nil]];
    
    return fetchRequest;
}

@end
