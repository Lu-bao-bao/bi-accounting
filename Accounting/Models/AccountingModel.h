//
//  AccountingModel.h
//  Accounting
//
//  Created by AmeRin on 26/10/2017.
//  Copyright © 2017 RM studio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Accounting+CoreDataClass.h"
#import "Accounting+CoreDataProperties.h"

@interface AccountingModel : NSObject
+(Accounting*)createAccounting:(NSManagedObjectContext *)context
                        amount:(NSDecimalNumber *)amount
                      category:(NSString *)category
                          tags:(NSString *)tags
                       comment:(NSString *)comment
                    createTime:(NSDate *)createTime
                successHandler:(void(^)(void))successHandler
                  errorHandler:(void(^)(NSError *error))errorHandler;

+(Accounting*)updateAccounting:(NSManagedObjectContext *)context
                      objectId:(NSManagedObjectID *)objectId
                        amount:(NSDecimalNumber *)amount
                      category:(NSString *)category
                          tags:(NSString *)tags
                       comment:(NSString *)comment
                    createTime:(NSDate *)createTime
                successHandler:(void(^)(void))successHandler
                  errorHandler:(void(^)(NSError *error))errorHandler;

+ (NSMutableDictionary *)transformAccountingToDictionary: (Accounting *)accounting;
+ (NSDecimalNumber *)sumOfAccountingAmounts: (NSManagedObjectContext *)context
                                 typeFilter: (NSString *)type
                                  beginDate: (NSDate *)beginDate
                                    endDate: (NSDate *)endDate;
@end
