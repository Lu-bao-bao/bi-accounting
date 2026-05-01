//
//  DatePickerDelegate.h
//  Accounting
//
//  Created by AmeRin on 9/12/2017.
//  Copyright © 2017 RM studio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define PICKER_START_YEAR 2010

@interface DatePickerDelegate : NSObject <UIPickerViewDelegate, UIPickerViewDataSource>
@property (nonatomic, assign) NSInteger selectedMonth;
@property (nonatomic, assign) NSInteger selectedYear;
@property (nonatomic, strong) NSString * selectedMode;
@property (nonatomic, strong) NSDate * selectedDate;
- (NSDate *)getSelectedDate;
- (void)selectCurrentDate:(UIPickerView *)pickerView;
@end
