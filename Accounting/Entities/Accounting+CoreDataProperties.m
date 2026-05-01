//
//  Accounting+CoreDataProperties.m
//  Accounting
//
//  Created by AmeRin on 20/10/2017.
//  Copyright © 2017 RM studio. All rights reserved.
//
//

#import "Accounting+CoreDataProperties.h"

@implementation Accounting (CoreDataProperties)

+ (NSFetchRequest<Accounting *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Accounting"];
}

@dynamic amount;
@dynamic category;
@dynamic comment;
@dynamic create_time;
@dynamic currency;
@dynamic id;
@dynamic last_sync_time;
@dynamic tags;
@dynamic user_id;

@end
