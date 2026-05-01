//
//  UIControl.m
//  AccountingToday
//
//  Created by AmeRin on 15/11/2017.
//  Copyright © 2017 RM studio. All rights reserved.
//

#import "UIControl+UIButton.h"
#import <objc/runtime.h>

@implementation UIControl(UIButton)

- (void)setCategoryName:(NSString *)name{
    objc_setAssociatedObject(self, @"categoryName", name, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)categoryName{
    return objc_getAssociatedObject(self, @"categoryName");
}
@end
