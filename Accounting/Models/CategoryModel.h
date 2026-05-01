//
//  CategoryModel.h
//  Accounting
//
//  Created by AmeRin on 20/10/2017.
//  Copyright © 2017 RM studio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Category+CoreDataClass.h"
#import "Category+CoreDataProperties.h"

@interface CategoryModel : NSObject
+ (Category *)appendCategory:(NSManagedObjectContext*)context
                        name:(NSString *)name icon:(NSString*)icon alias:(NSString *)alias type:(NSString *)type sequence:(NSInteger)sequence;
+ (NSArray *)getCategories:(NSManagedObjectContext*)context;
+ (NSArray *)getCategoriesByType:(NSString *)categoryType context:(NSManagedObjectContext*)context;
+ (Category *)getCategoryByName:(NSString *)categoryName context:(NSManagedObjectContext*)context;
+ (NSString *)getCategoryIconByName:(NSString *)categoryName context:(NSManagedObjectContext*)context;
+ (void)transAmountViaCategoryType:(NSDecimalNumber **)amount categoryName:(NSString *)categoryName context:(NSManagedObjectContext*)context;
@end
