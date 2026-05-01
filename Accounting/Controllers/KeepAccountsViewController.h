//
//  KeepAccountsViewController.h
//  Accounting
//
//  Created by AmeRin on 17/11/2017.
//  Copyright © 2017 RM studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KeepAccountsViewController : UIViewController <UIScrollViewDelegate>

// base
@property (nonatomic, strong) id accountingId;
@property (nonatomic, strong) NSString *accountingComment;
@property (nonatomic, strong) NSDate *accountingDate;
@property (nonatomic, strong) NSString *accountingCategory;
@property (nonatomic, strong) NSString *accountingTags;
@property (nonatomic, strong) NSDecimalNumber *accountingAmount;

@property (nonatomic, strong) NSArray *selectedTags;
@property (nonatomic, strong) NSString *categoryIcon;
@property (nonatomic, strong) NSDateFormatter * formatter;

// component
@property (weak, nonatomic) IBOutlet UILabel *digitBoard;
@property (weak, nonatomic) IBOutlet UIButton *dateButton;
@property (weak, nonatomic) IBOutlet UILabel *messageBoard;
@property (weak, nonatomic) IBOutlet UIButton *backspaceButton;
@property (weak, nonatomic) IBOutlet UIButton *datePickerButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UINavigationItem *noteTitleView;
@property (weak, nonatomic) IBOutlet UIButton *noteButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *noteBarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *tagsBarButton;
@property (weak, nonatomic) IBOutlet UIView *datePickerView;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@end
