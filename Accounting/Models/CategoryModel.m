//
//  CategoryModel.m
//  Accounting
//
//  Created by AmeRin on 20/10/2017.
//  Copyright © 2017 RM studio. All rights reserved.
//

#import "CategoryModel.h"
#import "Category+CoreDataClass.h"
#import "Category+CoreDataProperties.h"

#import "BaseModel.h"

@implementation CategoryModel

+ (NSFetchRequest *)getBaseCategoryFetchRequest:(NSManagedObjectContext*)context {
    return [BaseModel getBaseFetchRequest:context entityForName:@"Category"];
}

+ (Category *)appendCategory:(NSManagedObjectContext*)context
                        name:(NSString *)name icon:(NSString*)icon alias:(NSString *)alias type:(NSString *)type sequence:(NSInteger)sequence {

    if( name == nil || [name isEqualToString:@""] ) {
        NSLog(@"Warning: name is empty in CategoryModel::appendCategory.");
        return nil;
    }
    
    Category *category = [NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:context];
    category.name = name;
    category.icon = icon;
    category.alias = alias;
    category.type = type;
    category.sequence = sequence;

    NSError *error = nil;
    if( [context save:&error] ) {
        NSLog(@"Save success.");
        return category;
    } else {
        NSLog(@"%@", [NSString stringWithFormat:@"found core data error: %@", [error localizedDescription]]);
        return nil;
    }
}

+ (NSArray *)getCategories:(NSManagedObjectContext*)context {
    NSFetchRequest *fetchRequest = [self getBaseCategoryFetchRequest: context];

    NSError *error = nil;
    return [context executeFetchRequest:fetchRequest error:&error];
}

+ (NSArray *)getCategoriesByType:(NSString *)categoryType context:(NSManagedObjectContext*)context {
    NSFetchRequest *fetchRequest = [self getBaseCategoryFetchRequest: context];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type == %@", categoryType];
    [fetchRequest setPredicate:predicate];

    NSError *error = nil;
    return [context executeFetchRequest:fetchRequest error:&error];
}

+ (Category *)getCategoryByName:(NSString *)categoryName context:(NSManagedObjectContext*)context {
    NSFetchRequest *fetchRequest = [self getBaseCategoryFetchRequest: context];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", categoryName];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if( fetchedObjects == nil ) {
        NSLog(@"Nothing fetched.");
        return nil;
    }
    else {
        NSLog(@"getCategory: %@", [fetchedObjects firstObject]);
        return (Category *)[fetchedObjects firstObject];
    }
}

+ (NSString *)getCategoryIconByName:(NSString *)categoryName context:(NSManagedObjectContext*)context {
    Category *category = [self getCategoryByName:categoryName context:context];
    if(category) {
        return category.icon;
    }
    else {
        return @"";
    }
}

+ (void)transAmountViaCategoryType:(NSDecimalNumber **)amount categoryName:(NSString *)categoryName context:(NSManagedObjectContext*)context {
    Category *category = [CategoryModel getCategoryByName:categoryName context:context];
    if( category ) {
        if( [category.type isEqualToString:@"Expenses"] ) {
            if( [*amount compare: [NSNumber numberWithInt:0]] == NSOrderedDescending ) { // if amount > 0 then
                *amount = [*amount decimalNumberByMultiplyingBy:
                          [NSDecimalNumber decimalNumberWithMantissa:1 exponent:0 isNegative:YES]]; // amount = -amount
            }
        }
    }
}
@end
