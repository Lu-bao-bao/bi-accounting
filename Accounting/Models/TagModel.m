//
//  TagModel.m
//  Accounting
//
//  Created by AmeRin on 3/12/2017.
//  Copyright © 2017 RM studio. All rights reserved.
//

#import "TagModel.h"
#import "Tag+CoreDataClass.h"
#import "Tag+CoreDataProperties.h"

#import "BaseModel.h"

@implementation TagModel

+ (NSFetchRequest *)getBaseTagFetchRequest:(NSManagedObjectContext*)context {
    return [BaseModel getBaseFetchRequest:context entityForName:@"Tag"];
}

+ (Tag *)appendTag:(NSManagedObjectContext*)context
              name:(NSString *)name color:(NSInteger)color sequence:(NSInteger)sequence {
    
    Tag *tag = [NSEntityDescription insertNewObjectForEntityForName:@"Tag" inManagedObjectContext:context];
    tag.name = name;
    tag.color = (int_fast32_t)color;
    tag.sequence = sequence;
    
    NSError *error = nil;
    if( [context save:&error] ) {
        NSLog(@"Save success.");
        return tag;
    } else {
        NSLog(@"%@", [NSString stringWithFormat:@"found core data error: %@", [error localizedDescription]]);
        return nil;
    }
}

+ (void)updateTag:(Tag *)tag
              name:(NSString *)name color:(NSInteger)color sequence:(NSInteger)sequence
           context:(NSManagedObjectContext*)context {
    tag.name = name;
    tag.color = (int_fast32_t)color;
    tag.sequence = sequence;
    
    NSError *error = nil;
    if( [context save:&error] ) {
        NSLog(@"Save success.");
    } else {
        NSLog(@"%@", [NSString stringWithFormat:@"found core data error: %@", [error localizedDescription]]);
    }
}

+ (NSArray *)getTags:(NSManagedObjectContext*)context {
    NSFetchRequest *fetchRequest = [self getBaseTagFetchRequest: context];
    
    NSError *error = nil;
    return [context executeFetchRequest:fetchRequest error:&error];
}

@end
