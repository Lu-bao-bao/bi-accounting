//
//  SettingViewController.m
//  Accounting
//
//  Created by AmeRin on 3/11/2017.
//  Copyright © 2017 RM studio. All rights reserved.
//

#import "SettingViewController.h"
#import "CategoryViewController.h"
#import "TagSettingViewController.h"
#import "AboutUsViewController.h"
#import "AppDelegate.h"

#import "BudgetManager.h"

@interface SettingViewController ()
@property (weak, nonatomic) IBOutlet UITableView *settingTableView;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.settingTableView.delegate = self;
    self.settingTableView.dataSource = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    /*
     |-- Categories
     |-- Tags
     |-- Monthly Budget
     ---
     |-- Rate Our App
     |-- Share
     |-- About Us
     */
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (0==section) {
        return 3;
    } else {
        return 3;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Init
    NSMutableAttributedString *attrString;

    // Bugs: part of the buttom of some char like [gjpq] will covered in UITableViewCellStyleValue1 style.
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    //UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.font = [UIFont fontWithName:@"FontAwesome" size:16];

    if(0 == indexPath.section) {
        if (0 == indexPath.row) {
            attrString = [[NSMutableAttributedString alloc] initWithString:
                          @"\U0000F03A  Categories"];
        } else if (1 == indexPath.row) {
            attrString = [[NSMutableAttributedString alloc] initWithString:
                          @"\U0000F02C  Tags"];
        } else if (2 == indexPath.row) {
            attrString = [[NSMutableAttributedString alloc] initWithString:
                          @"\U0000F09D  Monthly Budget"];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.detailTextLabel.text = [BudgetManager getMonthlyBudgetString];
        }
    } else if (1 == indexPath.section) {
        if (0 == indexPath.row) {
            attrString = [[NSMutableAttributedString alloc] initWithString:
                          @"\U0000F005  Rate Our App"];
        } else if (1 == indexPath.row) {
            attrString = [[NSMutableAttributedString alloc] initWithString:
                          @"\U0000F1E0  Share"];
        } else if (2 == indexPath.row) {
            attrString = [[NSMutableAttributedString alloc] initWithString:
                          @"\U0000F0E0  About Us"];
        }
    }
    [attrString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"FontAwesome" size:16] range:NSMakeRange(0, 3)];
    [attrString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16.0f] range:NSMakeRange(4, [attrString length]-4)];
    
    cell.textLabel.attributedText = attrString;
    
    return cell;
}

#pragma mark Select row
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section) {
        if (0 == indexPath.row) {
            NSLog(@"CategoryViewController pressed.");
            CategoryViewController *c = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"category"];
            [self.navigationController showViewController:c sender:nil];
        } else if (1 == indexPath.row) {
            NSLog(@"TagSettingViewController pressed.");
            TagSettingViewController *c = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"tag"];
            [self.navigationController showViewController:c sender:nil];
        } else if (2 == indexPath.row) {
            [self showBudgetSettingAlert:self successHandler:^{
                [self.settingTableView reloadData];
            }];
        }
        
    } else if (1 == indexPath.section){
        if (0 == indexPath.row) {
            NSString *urlStr = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@?action=write-review", APP_ID];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]
                                               options:@{} completionHandler:^(BOOL success) {}];
        } else if (1 == indexPath.row) {
            NSString *textToShare = @"Bi Finance";
            UIImage *imageToShare = [UIImage imageNamed:@"AppIcon"];
            NSURL *urlToShare = [NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@", APP_ID]];
            NSArray *activityItems = @[textToShare, imageToShare, urlToShare];
            UIActivityViewController *controller = [[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities:nil];
            controller.excludedActivityTypes = @[UIActivityTypePrint,UIActivityTypeCopyToPasteboard,UIActivityTypeAssignToContact,UIActivityTypeSaveToCameraRoll];
            [self presentViewController:controller animated:YES completion:nil];
            controller.completionWithItemsHandler =
            ^(UIActivityType _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
                if (completed) {
                    NSLog(@"completed");
                } else  {
                    NSLog(@"cancled");
                }
            };
        } else if (2 == indexPath.row) {
            AboutUsViewController *c = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"about-us"];
            [self.navigationController showViewController:c sender:nil];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)showBudgetSettingAlert:(id)sender successHandler:(nonnull void (^)(void))successHandler {
    UIAlertController *alertController =
        [UIAlertController
            alertControllerWithTitle:@"Edit Budget"
                             message:[[NSString alloc]initWithFormat: @"Current budget: %@", [BudgetManager getMonthlyBudgetString]]
                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *saveAction =
        [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [BudgetManager setMonthlyBudget:
             [NSDecimalNumber decimalNumberWithString: alertController.textFields.firstObject.text]];
            
            successHandler();
    }];

    [alertController addAction:saveAction];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil]];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Monthly budget";
        textField.keyboardType = UIKeyboardTypeDecimalPad;
        textField.text = [[BudgetManager getMonthlyBudget] stringValue];
    }];

    [sender presentViewController:alertController animated:true completion:nil];
}

@end
