//
//  RMSPieView.h
//  Accounting
//
//  Created by AmeRin on 23/11/2017.
//  Copyright © 2017 RM studio. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kPieRandColor [UIColor colorWithRed:arc4random() % 255 / 255.0f green:arc4random() % 255 / 255.0f blue:arc4random() % 255 / 255.0f alpha:1.0f]

#define kPieRandWarmColor [UIColor colorWithRed:(255-arc4random()%150)/255.0f green:(100-arc4random()%100)/255.0f blue:0 alpha:1.0f]
#define kPieRandColdColor [UIColor colorWithRed:0 green:(200-arc4random()%150)/255.0f blue:(200-arc4random()%100)/255.0f alpha:1.0f]

@interface RMSPieView : UIView
- (void)setDatas:(NSArray <NSNumber *>*)datas
          colors:(NSArray <UIColor *>*)colors;
- (void)stroke;
@end
