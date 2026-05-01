//
//  EmptyInfoTableViewCell.m
//  Accounting
//
//  Created by AmeRin on 20/12/2017.
//  Copyright © 2017 RM studio. All rights reserved.
//

#import "EmptyInfoTableViewCell.h"
#import "Utils.h"

@implementation EmptyInfoTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.emptyIcon.text  = @"\U0000F01C";
    self.emptyIcon.font  = [UIFont fontWithName:@"FontAwesome" size:120];
    self.emptyLabel.text = @"You haven't made any note yet.";
    self.emptyLabel.font = [UIFont systemFontOfSize:16.0f];
    self.emptyLabel.textColor = [UIColor grayColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
