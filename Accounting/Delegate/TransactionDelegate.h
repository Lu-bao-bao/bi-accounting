//
//  TransactionDelegate.h
//  Accounting
//
//  Created by AmeRin on 16/11/2017.
//  Copyright © 2017 RM studio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TransactionDelegate : NSObject <UITableViewDataSource, UITableViewDelegate>
- (instancetype)initWithTableView:(UITableView *)tableView context:(NSManagedObjectContext *)context;
- (void)refreshDataFromDatabase: (UITableView *)tableView
                      beginDate: (NSDate *)beginDate
                        endDate: (NSDate *)endDate
                refreshFunction: (void(^)(void))refreshFunction;
- (void)classifyDataByCategoryType: (NSString *)categoryType;
- (void)classifyDataByDateFormat:(NSString *)dateFormat;
- (NSMutableDictionary *) getClassifiedData;
@end
