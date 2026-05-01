//
//  BudgetManager.h
//  Accounting
//
//  Created by AmeRin on 29/11/2017.
//  Copyright © 2017 RM studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BudgetManager : NSObject
+ (NSDecimalNumber *)getMonthlyBudget;
+ (NSString *)getMonthlyBudgetString;
+ (void)setMonthlyBudget:(NSDecimalNumber *) monthlyBudget;
@end
