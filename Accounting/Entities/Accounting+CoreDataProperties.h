//
//  Accounting+CoreDataProperties.h
//  Accounting
//
//  Created by AmeRin on 20/10/2017.
//  Copyright © 2017 RM studio. All rights reserved.
//
//

#import "Accounting+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Accounting (CoreDataProperties)

+ (NSFetchRequest<Accounting *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSDecimalNumber *amount;
@property (nullable, nonatomic, copy) NSString *category;
@property (nullable, nonatomic, copy) NSString *comment;
@property (nullable, nonatomic, copy) NSDate *create_time;
@property (nullable, nonatomic, copy) NSString *currency;
@property (nullable, nonatomic, copy) NSString *id;
@property (nullable, nonatomic, copy) NSDate *last_sync_time;
@property (nullable, nonatomic, copy) NSString *tags;
@property (nullable, nonatomic, copy) NSString *user_id;

@end

NS_ASSUME_NONNULL_END
