//
//  NumberPad.h
//  Accounting
//
//  Created by AmeRin on 25/10/2017.
//  Copyright © 2017 RM studio. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSInteger const NUMPAD_PURE_INT_PART;
extern NSInteger const NUMPAD_PURE_FLOAT_PART;

@interface NumberPad : NSObject
@property (nonatomic, strong) NSString *numberPad;
- (id)init;
- (id)initWithString:(NSString *)numberValue;
- (void)clear;
- (NSArray *)numberDivision;
- (void)appendDigit: (char)digit;
- (void)appendDot;
- (void)attachBackspace;
- (NSString *)getNumberPad;
- (NSString *)getNumberPadForCurrencyStyle;
- (NSDecimalNumber *)getDecimalNumber;
@end
