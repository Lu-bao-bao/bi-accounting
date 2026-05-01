//
//  RMSPieView.m
//  Accounting
//
//  Created by AmeRin on 23/11/2017.
//  Copyright © 2017 RM studio. All rights reserved.
//

#import "RMSPieView.h"

@interface RMSLayer : CAShapeLayer
@property (nonatomic,assign)CGFloat startAngle;
@property (nonatomic,assign)CGFloat endAngle;
@property (nonatomic,assign)BOOL    isSelected;
@end

@implementation RMSLayer
@end

#define Hollow_Circle_Radius 0
#define KOffsetRadius 10
#define KMargin 20

@interface RMSPieView () {
    CAShapeLayer *_maskLayer;
    CGFloat _radius;
    CGFloat _lineWidth;
    CGPoint _center;
}
@end

@implementation RMSPieView


- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        _lineWidth = 50;
        _radius = (frame.size.width - KMargin*2)/4.f;
        _center = CGPointMake(_radius*2 + KMargin, _radius*2 + KMargin);
        
        _maskLayer = [CAShapeLayer layer];
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithArcCenter:_center radius:self.bounds.size.width/4.f startAngle:-M_PI_2 endAngle:M_PI_2*3 clockwise:YES];
        _maskLayer.strokeColor = [UIColor greenColor].CGColor;
        _maskLayer.lineWidth = self.bounds.size.width/2.f + _lineWidth;
        _maskLayer.fillColor = [UIColor clearColor].CGColor;
        _maskLayer.path = maskPath.CGPath;
        _maskLayer.strokeEnd = 0;
        self.layer.mask = _maskLayer;
    }
    
    return self;
}

#pragma mark -- Publish Methods
- (void)setDatas:(NSArray <NSNumber *>*)datas
          colors:(NSArray <UIColor *>*)colors {
    
    NSArray *newDatas = [self getPersentArraysWithDataArray:datas];
    
    CGFloat start = -M_PI_2;
    CGFloat end = start;
    
    while (newDatas.count > self.layer.sublayers.count) {
        RMSLayer *pieLayer = [RMSLayer layer];
        pieLayer.fillColor = [UIColor clearColor].CGColor; // not close, cannot fill color.
        pieLayer.lineWidth = _lineWidth;
        [self.layer addSublayer:pieLayer];
    }
    
    for (int i = 0; i < self.layer.sublayers.count; i ++) {
        
        RMSLayer *pieLayer = (RMSLayer *)self.layer.sublayers[i];
        if (i < newDatas.count) {
            pieLayer.hidden = NO;
            end =  start + M_PI * 2 * [newDatas[i] floatValue];
            
            UIBezierPath *piePath = [UIBezierPath bezierPath];
            [piePath addArcWithCenter:_center radius:_radius*2 startAngle:start endAngle:end clockwise:YES];
            
            pieLayer.strokeColor = [colors.count > i?colors[i]:kPieRandColor CGColor];
            pieLayer.startAngle = start;
            pieLayer.endAngle = end;
            pieLayer.path = piePath.CGPath;
            
            NSLog(@"pieLayer.path: %@", pieLayer.path);
            
            start = end;
        } else {
            pieLayer.hidden = YES;
        }
    }
}

- (void)stroke {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.duration = 1.f;
    animation.fromValue = [NSNumber numberWithFloat:0.f];
    animation.toValue = [NSNumber numberWithFloat:1.f];
    animation.autoreverses = NO;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [_maskLayer addAnimation:animation forKey:@"strokeEnd"];
}

#pragma mark -- Privite Methods
- (NSArray *)getPersentArraysWithDataArray:(NSArray *)datas{
    NSArray *newDatas = datas;
    /*
    NSArray *newDatas = [datas sortedArrayUsingComparator:^NSComparisonResult(id _Nonnull obj1, id _Nonnull obj2) {
        if (fabs([obj1 floatValue]) < fabs([obj2 floatValue])) {
            return NSOrderedDescending;
        }else if (fabs([obj1 floatValue]) > fabs([obj2 floatValue])){
            return NSOrderedAscending;
        }else{
            return NSOrderedSame;
        }
    }];
     */
    
    NSMutableArray *persentArray = [NSMutableArray array];
    NSNumber *sum = [newDatas valueForKeyPath:@"@sum.floatValue"];
    for (NSNumber *number in newDatas) {
        [persentArray addObject:@(number.floatValue/sum.floatValue)];
    }
    NSLog(@"persentArray: %@", persentArray);
    
    return persentArray;
}

/*
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    CGPoint point = [touches.anyObject locationInView:self];
    [self upDateLayersWithPoint:point];
    
    NSLog(@"%@",NSStringFromCGPoint(point));
}

- (void)upDateLayersWithPoint:(CGPoint)point{
    
    for (RMSLayer *layer in self.layer.sublayers) {
        
        if (CGPathContainsPoint(layer.path, &CGAffineTransformIdentity, point, 0) && !layer.isSelected) {
            layer.isSelected = YES;
            
            CGPoint currPos = layer.position;
            double middleAngle = (layer.startAngle + layer.endAngle)/2.0;
            CGPoint newPos = CGPointMake(currPos.x + KOffsetRadius*cos(middleAngle), currPos.y + KOffsetRadius*sin(middleAngle));
            layer.position = newPos;
            
        } else {
            layer.position = CGPointMake(0, 0);
            layer.isSelected = NO;
        }
    }
}
*/

@end
