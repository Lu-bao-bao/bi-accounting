//
//  SettingViewController.h
//  Accounting
//
//  Created by AmeRin on 3/11/2017.
//  Copyright © 2017 RM studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
- (void)showBudgetSettingAlert:(id _Nonnull)sender successHandler:(nonnull void (^)(void))successHandler;
@end
