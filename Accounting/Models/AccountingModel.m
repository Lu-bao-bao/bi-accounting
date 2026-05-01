//
//  AccountingModel.m
//  Accounting
//
//  Created by AmeRin on 26/10/2017.
//  Copyright © 2017 RM studio. All rights reserved.
//

#import "AccountingModel.h"
#import "Accounting+CoreDataClass.h"
#import "Accounting+CoreDataProperties.h"

@implementation AccountingModel

+(Accounting*)createAccounting:(NSManagedObjectContext *)context
                        amount:(NSDecimalNumber *)amount
                      category:(NSString *)category
                          tags:(NSString *)tags
                       comment:(NSString *)comment
                    createTime:(NSDate *)createTime
                successHandler:(void(^)(void))successHandler
                  errorHandler:(void(^)(NSError *error))errorHandler
{
    return [self updateAccounting:context objectId:nil amount:amount category:category tags:tags comment:comment createTime:createTime successHandler:successHandler errorHandler:errorHandler];
}

+(Accounting*)updateAccounting:(NSManagedObjectContext *)context
                      objectId:(NSManagedObjectID *)objectId
                        amount:(NSDecimalNumber *)amount
                      category:(NSString *)category
                          tags:(NSString *)tags
                       comment:(NSString *)comment
                    createTime:(NSDate *)createTime
                successHandler:(void(^)(void))successHandler
                  errorHandler:(void(^)(NSError *error))errorHandler
{
    // If amount is unavalible.
    if([[NSDecimalNumber notANumber] isEqualToNumber: amount]) {
        return nil;
    }
    
    Accounting *accounting;
    if( objectId == nil ) {
        // Create new accounting.
        accounting = [NSEntityDescription insertNewObjectForEntityForName:@"Accounting" inManagedObjectContext: context];
    } else {
        // Update existing accounting.
        accounting = [context objectWithID:objectId];
    }
    
    accounting.amount = amount;
    accounting.tags = tags;
    accounting.category = category;
    accounting.comment = comment;
    accounting.create_time = createTime;
    
    // Save context.
    NSError *error = nil;
    if( [context save:&error] ) {
        NSLog(@"Context save success.");
        successHandler();
        return accounting;
    } else {
        NSLog(@"%@", [NSString stringWithFormat:@"found core data error: %@", [error localizedDescription]]);
        errorHandler(error);
        return nil;
    }
}


+ (NSDecimalNumber *)sumOfAccountingAmounts: (NSManagedObjectContext *)context
                                 typeFilter: (NSString *)type
                                  beginDate: (NSDate *)beginDate
                                    endDate: (NSDate *)endDate {

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.resultType = NSDictionaryResultType;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Accounting" inManagedObjectContext:context];
    
    // Predicates init
    NSMutableArray *subPredicates = [[NSMutableArray alloc] init];
    
    // Type predicate
    if([type isEqualToString:@"Expenses"] || [type isEqualToString:@"Income"]) {
        NSPredicate *predicate_type;
        if( [type isEqualToString:@"Expenses"] ) {
            predicate_type = [NSPredicate predicateWithFormat:@"amount < 0"];
        }
        else {
            predicate_type = [NSPredicate predicateWithFormat:@"amount > 0"];
        }
        [subPredicates addObject:predicate_type];
    }

    // Date predicate
    if(beginDate && endDate) {
        NSPredicate *predicate_date = [NSPredicate predicateWithFormat:@"create_time >= %@ AND create_time <= %@", beginDate, endDate];
        [subPredicates addObject:predicate_date];
    }
    
    // Compound predicate !? what a f**k operation.
    NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:subPredicates];
    [fetchRequest setPredicate:predicate];
    
    // Set entity
    [fetchRequest setEntity:entity];
    
    NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
    expressionDescription.name = @"sumOfAmounts";
    expressionDescription.expression = [NSExpression expressionForKeyPath:@"@sum.amount"];
    expressionDescription.expressionResultType = NSDecimalAttributeType;

    fetchRequest.propertiesToFetch = @[expressionDescription];
    
    NSError *error = nil;
    NSDecimalNumber *sumOfAmounts = [NSDecimalNumber zero];
    
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if( fetchedObjects == nil ) {
        NSLog(@"Nothing fetched.");
    }
    else {
        sumOfAmounts = [[fetchedObjects objectAtIndex:0] objectForKey:@"sumOfAmounts"];
    }
    
    return sumOfAmounts;
}

+ (NSMutableDictionary *)transformAccountingToDictionary: (Accounting *)accounting {
    NSMutableDictionary *dictAccounting = [[NSMutableDictionary alloc] init];
    [dictAccounting setObject:accounting.objectID == nil ? @"" : accounting.objectID  forKey:@"objectID"];
    [dictAccounting setObject:accounting.amount == nil ? @"" : accounting.amount      forKey:@"amount"];
    [dictAccounting setObject:accounting.tags == nil ? @"" : accounting.tags          forKey:@"tags"];
    [dictAccounting setObject:accounting.category == nil ? @"" : accounting.category  forKey:@"category"];
    [dictAccounting setObject:accounting.comment == nil ? @"" : accounting.comment    forKey:@"comment"];
    [dictAccounting setObject:accounting.create_time forKey:@"create_time"];
    return dictAccounting;
}

@end
