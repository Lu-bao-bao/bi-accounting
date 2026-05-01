//
//  CALayer+Addition.m
//  Accounting
//
//  Created by AmeRin on 19/11/2017.
//  Copyright © 2017 RM studio. All rights reserved.
//

#import "CALayer+Addition.h"
#import <objc/runtime.h>

@implementation CALayer (Addition)

- (UIColor *)borderUIColor {
    return objc_getAssociatedObject(self, @selector(borderUIColor));
}

-(void)setBorderUIColor:(UIColor *)color {
    objc_setAssociatedObject(self, @selector(borderUIColor), color, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.borderColor = color.CGColor;
}

@end
