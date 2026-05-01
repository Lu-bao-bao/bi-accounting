//
//  Utils.h
//  Accounting
//
//  Created by AmeRin on 25/10/2017.
//  Copyright © 2017 RM studio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define UI_IS_LANDSCAPE         ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft || [UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight)
#define UI_IS_IPAD              ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
#define UI_IS_IPHONE            ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
#define UI_IS_IPHONE4           (UI_IS_IPHONE && [[UIScreen mainScreen] bounds].size.height < 568.0)
#define UI_IS_IPHONE5_S_E       (UI_IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0)
#define UI_IS_IPHONE6_S_OR_HIGHER           (UI_IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 667.0)
#define UI_IS_IPHONE6_S_PLUS_OR_HIGHER       (UI_IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 736.0 || [[UIScreen mainScreen] bounds].size.width == 736.0) // Both orientations

#define UIColorFromHex(s)   [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:1.0]

@interface Utils : NSObject
+ (BOOL)isPureInt:  (NSString*)string;
+ (BOOL)isPureFloat:(NSString*)string;
+ (NSDecimalNumber *)decimalNumberAbs:(NSDecimalNumber *)num;
+ (NSDictionary<id, NSDate *>*)getBeginAndEndWith:(NSDate *)newDate byRangeOfUnit:(NSCalendarUnit)unit;
+ (UIImage *)imageWithColor:(UIColor *)color andRect:(CGRect)rect;
+ (BOOL)stringContainsEmoji:(NSString *)string;
@end
