//
//  RMSSlider.m
//  Accounting
//
//  Created by AmeRin on 8/12/2017.
//  Copyright © 2017 RM studio. All rights reserved.
//

#import "RMSSlider.h"
#import "UIImage+UIImageExtras.h"
#import "Utils.h"

#define SLIDER_COLOR 0x008B8B
//#define BACKGROUND_COLOR 0x243E3E
#define BACKGROUND_COLOR 0xbbbbbb

@interface RMSSlider()
@property (nonatomic ,strong) UILabel *label;
@property (nonatomic, assign) CGRect frame;
@property (nonatomic, assign) CGFloat height;
@end

@implementation RMSSlider

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        // start here.
        self.height = 55.0;
        [self createSlider];
    }
    return self;
}

- (CGRect)trackRectForBounds:(CGRect)bounds{
    bounds = [super trackRectForBounds:bounds];
    return CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width, self.height);
}

- (void)createSlider {
    [self setMinimumTrackImage:[[Utils imageWithColor:UIColorFromHex(SLIDER_COLOR) andRect:CGRectMake(0.0f, 0.0f, self.height, self.height)] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 14, 0, 14)] forState:UIControlStateNormal];
    [self setMaximumTrackImage:[[Utils imageWithColor:UIColorFromHex(BACKGROUND_COLOR) andRect:CGRectMake(0.0f, 0.0f, self.height, self.height)] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 14, 0, 14)] forState:UIControlStateNormal];
    self.layer.masksToBounds = NO;
    self.layer.cornerRadius = 0.0;
    self.layer.backgroundColor = [UIColor.whiteColor CGColor];
    UIImage *sliderImage = [UIImage imageNamed:@"slider-button-2"];
    
    [self setThumbImage:[sliderImage imageByScalingToSize:CGSizeMake(self.height, self.height)] forState:UIControlStateNormal];
    [self addTarget:self action:@selector(sliderValueChanged:) forControlEvents: UIControlEventValueChanged];

    self.label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.frame.size.height)];

    self.label.text = @"Slide to charge up.";
    self.label.font = [UIFont systemFontOfSize: 16];
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.textColor = [UIColor whiteColor];
    self.label.layer.masksToBounds = NO;
    self.label.layer.cornerRadius = 0;
    self.label.layer.borderWidth = 0;
    self.label.layer.borderColor = [UIColor.grayColor CGColor];
    self.label.layer.zPosition = 1;
    [self addSubview: self.label];
}

- (void)sliderValueChanged:(UISlider *)slider {
    [self setValue:slider.value animated: YES];
    if (slider.value > 0) {
        [self setMinimumTrackImage:[[Utils imageWithColor:UIColorFromHex(SLIDER_COLOR) andRect:CGRectMake(0.0f, 0.0f, self.height, self.height)] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 14, 0, 14)] forState:UIControlStateNormal];
    } else {
        //[self setMinimumTrackImage:[[Utils imageWithColor:[UIColor clearColor] andRect:CGRectMake(0.0f, 0.0f, self.height, self.height)] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 14, 0, 14)] forState:UIControlStateNormal];
    }
    
    if (!slider.isTracking && slider.value < .85 /* Full width is set to 85% */) {
        [self setValue:0 animated:YES];
        if (slider.value > 0 ) {
            [self setMinimumTrackImage:[[Utils imageWithColor:UIColorFromHex(SLIDER_COLOR) andRect:CGRectMake(0.0f, 0.0f, self.height, self.height)] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 14, 0, 14)] forState:UIControlStateNormal];
        } else {
        }
    }
    else if( slider.value >= .85 ) {
        [self setValue:1 animated:YES];
    }
}
@end
