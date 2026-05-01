//
//  NumberPad.m
//  Accounting
//
//  Created by AmeRin on 25/10/2017.
//  Copyright © 2017 RM studio. All rights reserved.
//

#import "NumberPad.h"
#import "Utils.h"

@implementation NumberPad

NSInteger const NUMPAD_PURE_INT_PART = 0;
NSInteger const NUMPAD_PURE_FLOAT_PART = 1;

static int INT_LIMIT = 10, FLOAT_LIMIT = 2; // $##########.##

- (id)init {
    if( self = [super init] ) {
        self.numberPad = @"0";
    }
    return self;
}

- (id)initWithString:(NSString *)numberValue {
    if( self = [super init] ) {
        self.numberPad = numberValue;
    }
    return self;
}

- (NSArray *)numberDivision {
    NSMutableArray *digits = [NSMutableArray arrayWithArray:[self.numberPad componentsSeparatedByString:@"."]];
    if([digits count] == 1) [digits addObject: @""];

    return [[NSArray alloc] initWithArray:digits];
}

- (void)clear {
    self.numberPad = @"0";
}

- (void)appendDigit: (char)digit {
    if( digit >= '0' && digit <= '9' ) {
        NSArray *digits = [self numberDivision];
    
        if(!([Utils isPureInt: self.numberPad] || [Utils isPureFloat: self.numberPad]) ||
           [self.numberPad isEqualToString:@"0"]) self.numberPad = @"";
        if( ([digits[NUMPAD_PURE_INT_PART] length] >= INT_LIMIT && [Utils isPureInt: self.numberPad]) ||
           [digits[NUMPAD_PURE_FLOAT_PART] length] >= FLOAT_LIMIT ) return;
    
        self.numberPad = [self.numberPad stringByAppendingFormat:@"%c", digit];
    }
}

- (void)appendDot {
    // '.', dot
    if([Utils isPureInt: self.numberPad]) {
        self.numberPad = [self.numberPad stringByAppendingString: @"."];
    }
}

- (void)attachBackspace {
    // '<', backspace
    if( [self.numberPad length] > 1 ) {
        self.numberPad = [self.numberPad substringToIndex: [self.numberPad length] - 1];
    }
    else {
        self.numberPad = @"0";
    }
}

- (NSString *)getNumberPad {
    return self.numberPad;
}

- (NSString *)getNumberPadForCurrencyStyle {
    NSString *numberCurrencyStyleStr = [NSNumberFormatter localizedStringFromNumber:[self getDecimalNumber] numberStyle:NSNumberFormatterCurrencyStyle];
    return numberCurrencyStyleStr;
}

- (NSDecimalNumber *)getDecimalNumber {
    return [NSDecimalNumber decimalNumberWithString: self.numberPad];
}

@end
