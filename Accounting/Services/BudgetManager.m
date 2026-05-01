//
//  BudgetManager.m
//  Accounting
//
//  Created by AmeRin on 29/11/2017.
//  Copyright © 2017 RM studio. All rights reserved.
//

#import "BudgetManager.h"

@implementation BudgetManager
+ (NSDecimalNumber *)getMonthlyBudget {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDecimalNumber *monthlyBudget = [userDefaults objectForKey:@"monthlyBudget"];
    if(!monthlyBudget) {
        monthlyBudget = [NSDecimalNumber zero];
        [userDefaults setObject:monthlyBudget forKey:@"monthlyBudget"];
        [userDefaults synchronize];
    }
    return monthlyBudget;
}

+ (NSString *)getMonthlyBudgetString {
    return [NSNumberFormatter localizedStringFromNumber:[BudgetManager getMonthlyBudget] numberStyle:NSNumberFormatterCurrencyStyle];
}

+ (void)setMonthlyBudget:(NSDecimalNumber *) monthlyBudget {
    if( [monthlyBudget isEqual: [NSDecimalNumber notANumber]] ) {
        monthlyBudget = [NSDecimalNumber zero];
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:monthlyBudget forKey:@"monthlyBudget"];
    [userDefaults synchronize];
}
@end
