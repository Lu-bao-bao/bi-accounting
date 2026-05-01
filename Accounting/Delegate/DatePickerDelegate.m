//
//  DatePickerDelegate.m
//  Accounting
//
//  Created by AmeRin on 9/12/2017.
//  Copyright © 2017 RM studio. All rights reserved.
//

#import "DatePickerDelegate.h"

@interface DatePickerDelegate () {
    NSInteger yearRange;
    NSInteger startYear;
}
@end

@implementation DatePickerDelegate

- (instancetype)init
{
    if(self = [super init]) {
        // init
        yearRange = 90;
        self.selectedMode = @"normal";
    }
    return self;
}

#pragma mark - UIPickerViewDelegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (component == 0) {
        return 12 + 4;
    } else {
        return yearRange;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if( component == 0 ) {
        NSString *itemName;
        if( row < 12 ) {
            // transform month number to name.
            int monthNumber = (int)row;
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            itemName = [[df monthSymbols] objectAtIndex: monthNumber];
        }
        else if( row == 12 ) {
            itemName = @"---";
            
        }
        else if( row == 13 ) itemName = @"Whole Year";
        else if( row == 14 ) itemName = @"All Time";
        else if( row == 15 ) itemName = @"Current Time";

        return [NSString stringWithFormat:@"%@", itemName];
    } else {
        return [NSString stringWithFormat:@"%ld", (long)(PICKER_START_YEAR + row)];
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if( component == 0 && row >= 12 ) {
        switch (row) {
            case 12: {
                [pickerView selectRow: row + 1 inComponent:0 animated:YES];
                break;
            }
            case 15: {
                [self selectCurrentDate:pickerView];
                break;
            }
            default: break;
        }
    }
    
    if( [pickerView selectedRowInComponent:0] > 12 ) {
        switch ([pickerView selectedRowInComponent:0]) {
            case 13: {
                self.selectedMode = @"whole_year";
                self.selectedYear  = (long)[pickerView selectedRowInComponent:1] + PICKER_START_YEAR;
                self.selectedMonth = 1;
                break;
            }
            case 14: {
                self.selectedMode = @"all";
                self.selectedYear = 0; self.selectedMonth = 0;
                break;
            }
            default: break;
        }
    }
    else {
        NSLog(@"Date picker selected: %ld Month, %ld Year",
              (long)[pickerView selectedRowInComponent:0]+1, PICKER_START_YEAR + (long)[pickerView selectedRowInComponent:1]);
        
        self.selectedMode = @"normal";
        self.selectedYear  = (long)[pickerView selectedRowInComponent:1] + PICKER_START_YEAR;
        self.selectedMonth = (long)[pickerView selectedRowInComponent:0] + 1;
    }
}

- (NSDate *)getSelectedDate {
    if( [self.selectedMode isEqualToString: @"all"] ) {
        return nil;
    }
    else {
        NSString *string = [[NSString alloc]initWithFormat:@"%04ld-%02ld", (long)self.selectedYear, (long)self.selectedMonth];
        
        NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
        fmt.dateFormat = @"yyyy-MM";
        
        NSLog(@"getSelectedDate: %@", [fmt dateFromString:string]);
        
        // NSString * -> NSDate *
        return [fmt dateFromString:string];
    }
}

- (void)selectCurrentDate:(UIPickerView *)pickerView {
    NSDate *now = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents* date = [gregorian components: NSCalendarUnitYear | NSCalendarUnitMonth fromDate: now];
    [pickerView selectRow:date.month-1 inComponent:0 animated: YES];
    [pickerView selectRow:date.year-PICKER_START_YEAR inComponent:1 animated: YES];
}

@end
