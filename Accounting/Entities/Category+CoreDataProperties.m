//
//  Category+CoreDataProperties.m
//  Accounting
//
//  Created by AmeRin on 20/10/2017.
//  Copyright © 2017 RM studio. All rights reserved.
//
//

#import "Category+CoreDataProperties.h"

@implementation Category (CoreDataProperties)

+ (NSFetchRequest<Category *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Category"];
}

@dynamic alias;
@dynamic icon;
@dynamic name;
@dynamic sequence;
@dynamic type;

@end
