//
//  TagModel.h
//  Accounting
//
//  Created by AmeRin on 3/12/2017.
//  Copyright © 2017 RM studio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Tag+CoreDataClass.h"
#import "Tag+CoreDataProperties.h"

@interface TagModel : NSObject
+ (Tag *)appendTag:(NSManagedObjectContext*)context
              name:(NSString *)name color:(NSInteger)color sequence:(NSInteger)sequence;
+ (void)updateTag:(Tag *)tag
              name:(NSString *)name color:(NSInteger)color sequence:(NSInteger)sequence
           context:(NSManagedObjectContext*)context;
+ (NSArray *)getTags:(NSManagedObjectContext*)context;
@end
