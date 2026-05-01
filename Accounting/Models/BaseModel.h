//
//  BaseModel.h
//  Accounting
//
//  Created by AmeRin on 26/10/2017.
//  Copyright © 2017 RM studio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface BaseModel : NSObject
+ (NSManagedObjectContext *)setupCoreDataStackWithStoreNamed:(NSString *)storeNamed;
+ (NSFetchRequest *)getBaseFetchRequest:(NSManagedObjectContext*)context entityForName:(NSString*)entityName;
@end
