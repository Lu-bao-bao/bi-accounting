//
//  TransactionTableViewCell.h
//  Accounting
//
//  Created by AmeRin on 22/11/2017.
//  Copyright © 2017 RM studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TransactionTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *categoryIconLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryNameLabel;
@property (weak, nonatomic) IBOutlet UIView *categoryColorView;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@end
