//
//  ViewController.m
//  Accounting
//
//  Created by AmeRin on 9/10/2017.
//  Copyright © 2017 RM studio. All rights reserved.
//

#import "ViewController.h"
#import "KeepAccountsViewController.h"
#import "SettingViewController.h"

#import "Category+CoreDataClass.h"
#import "Category+CoreDataProperties.h"

#import "CategoryModel.h"
#import "AccountingModel.h"

#import "BudgetManager.h"
#import "Utils.h"

#import "TransactionDelegate.h"
#import "DatePickerDelegate.h"
#import "AppDelegate.h"

#import "RMSPieView.h"
#import "RMSSlider.h"

@interface ViewController () 
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (weak, nonatomic) IBOutlet UIView *blankView;
@property (weak, nonatomic) IBOutlet UITableView *transactionTableView;
@property (weak, nonatomic) IBOutlet UIView *pieView;
@property (weak, nonatomic) IBOutlet UIPickerView *customDatePicker;
@property (strong, nonatomic) IBOutlet UIView *datePickerView;
@property (weak, nonatomic) IBOutlet UIView *datePickerContentView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalAmountLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *budgetLeftProgress;
@property (weak, nonatomic) IBOutlet UIView *summaryView;
@property (weak, nonatomic) IBOutlet UILabel *budgetLeftLabel;
@property (weak, nonatomic) IBOutlet UILabel *exchangeLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *budgetRemainProgress;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UIButton *chargeUpButton;

@property (nonatomic, strong) UIPickerView *categoryPickerView;
@property (nonatomic, strong) NSArray *categoryArray;
@property (nonatomic, strong) NSString *selectedCategory;
@property (nonatomic, strong) NSString *choosedReportViewType;

@property (nonatomic, strong) NSDictionary<id, NSDate *>* dateRange;
@property (nonatomic, strong) NSDate *beginDate;
@property (nonatomic, strong) NSDate *endDate;

@property (nonatomic, strong) TransactionDelegate *transactionDelegate;
@property (nonatomic, strong) DatePickerDelegate *datePickerDelegate;
@property (nonatomic, strong) NSLayoutConstraint *pieViewHeightConstraint;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // Load context.
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.context = delegate.persistentContainer.viewContext;
    
    // Load view from xib
    [[NSBundle mainBundle] loadNibNamed:@"ViewController" owner:self options:nil];

    // Load view start

    // Hide navigation bar shadow.
    [self.navigationController.navigationBar
        setBackgroundImage:[[UIImage alloc] init]
            forBarPosition:UIBarPositionAny
                barMetrics:UIBarMetricsDefault];
    
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];

    // Set table view.
    self.transactionDelegate = [[TransactionDelegate alloc] initWithTableView:self.transactionTableView context: self.context];
    self.transactionTableView.dataSource = self.transactionDelegate;
    self.transactionTableView.delegate = self.transactionDelegate;
    self.transactionTableView.rowHeight = UITableViewAutomaticDimension;

    static NSString* cellIdentity = @"TransactionTableViewCell";
    [self.transactionTableView registerNib:[UINib nibWithNibName:@"EmptyInfoTableViewCell" bundle: nil]  forCellReuseIdentifier:@"EmptyInfoTableViewCell"];
    [self.transactionTableView registerNib:[UINib nibWithNibName:@"TransactionTableViewCell" bundle:nil] forCellReuseIdentifier:cellIdentity];
    
    // Set date label
    [self setDateAndDateLabel:[NSDate date] mode:nil];

    // date label
    self.dateLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *labelTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(labelTouchUpInside:)];
    [self.dateLabel addGestureRecognizer:labelTapGestureRecognizer];
    
    // custom date picker
    self.datePickerDelegate = [[DatePickerDelegate alloc]init];
    self.customDatePicker.dataSource = self.datePickerDelegate;
    self.customDatePicker.delegate = self.datePickerDelegate;
    [self.datePickerDelegate selectCurrentDate:self.customDatePicker];

    // date picker view
    [self.datePickerContentView addSubview: self.datePickerView];
    self.datePickerView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 200);

    // hide pie view
    self.pieView.translatesAutoresizingMaskIntoConstraints = NO;
    self.pieViewHeightConstraint = [self.pieView.heightAnchor constraintEqualToConstant:0];
    [self.pieViewHeightConstraint setActive:true];
    [self.pieView setHidden:YES];
    
    // budget progress bar init
    [self.budgetLeftProgress setProgress: 0.0 animated:NO];
    self.budgetLeftProgress.clipsToBounds = YES;
    self.budgetLeftProgress.layer.cornerRadius = 20 / 2.0;
    self.budgetLeftProgress.progressViewStyle = UIProgressViewStyleDefault;
    [self.budgetLeftProgress setProgressTintColor: [UIColor whiteColor]];
    [self.budgetLeftProgress.subviews enumerateObjectsUsingBlock:
     ^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.layer.masksToBounds = YES;
        obj.layer.cornerRadius = 20 / 2.0;
    }];
}

- (void) setDateAndDateLabel:(NSDate *)currentDate mode:(NSString *)mode {
    
    NSString *currentDateString = nil;
    
    if( currentDate == nil || [mode isEqualToString:@"all"] ) {
        self.beginDate = nil;
        self.endDate = nil;
        
        currentDateString = @"ALL \n▼";
    }
    else {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        
        if( [mode isEqualToString:@"whole_year"] ) {
            self.dateRange = [Utils getBeginAndEndWith:currentDate byRangeOfUnit:NSCalendarUnitYear];
            [formatter setDateFormat:@"yyyy\n ▼"];
        }
        else {
            self.dateRange = [Utils getBeginAndEndWith:currentDate byRangeOfUnit:NSCalendarUnitMonth];
            [formatter setDateFormat:@"MMM \nyyyy ▼"];
        }
        self.beginDate = self.dateRange[@"beginDate"];
        self.endDate = self.dateRange[@"endDate"];
        currentDateString = [formatter stringFromDate:currentDate];
    }
    
    NSMutableAttributedString *attrString =
    [[NSMutableAttributedString alloc] initWithString: [currentDateString uppercaseString]];
    
    @try {
        [attrString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:33.0f] range:NSMakeRange(0, 4)];
        [attrString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14.0f] range:NSMakeRange(5, [attrString length]-5)];
    }
    @catch(NSException *e) {
        NSLog(@"string format is not correct.");
    }

    [attrString addAttribute:NSForegroundColorAttributeName
                       value:[UIColor whiteColor]
                       range:NSMakeRange(0, [attrString length])];
    
    [self.dateLabel setAttributedText:attrString];
}

- (NSDictionary *)getPieDataByCategoryType:(NSString *)type {
    NSMutableDictionary *classifiedData = [self.transactionDelegate getClassifiedData];
    NSMutableArray *classifiedTypeArray = classifiedData[type];
    
    NSMutableDictionary *pieData = [[NSMutableDictionary alloc]init];
    [pieData setObject:[[NSMutableArray alloc]init] forKey:@"amounts"];
    [pieData setObject:[[NSMutableArray alloc]init] forKey:@"colors"];
    for (NSMutableDictionary *dict in classifiedTypeArray) {
        [pieData[@"amounts"] addObject: dict[@"amount"]];
        [pieData[@"colors"]  addObject: dict[@"color"]];
    }
    
    NSLog(@"classifiedData: %@", classifiedData);
    NSLog(@"pieData: %@", pieData);
    
    return pieData;
}

- (void)loadViewData {
    // Load data
    
    // Report view
    if( self.choosedReportViewType == nil || [self.choosedReportViewType isEqualToString:@""] ) {
        self.choosedReportViewType = @"Expenses";
    }

    // Budget view
    NSDecimalNumber *totalAmount =
        [AccountingModel sumOfAccountingAmounts:self.context typeFilter:@"Expenses"
                                      beginDate:self.beginDate endDate:self.endDate];
    NSDecimalNumber *monthlyBudget = [NSDecimalNumber decimalNumberWithString: [[BudgetManager getMonthlyBudget] stringValue]];
    NSDecimalNumber *budgetLeft = [monthlyBudget decimalNumberByAdding:totalAmount];
    
    // budget progress 
    CGFloat budgetRatio = 0;
    if( [budgetLeft compare:[NSDecimalNumber zero]] == NSOrderedAscending ||
        [monthlyBudget compare:[NSDecimalNumber zero]] == NSOrderedSame ) {
        budgetRatio = 1;
    }
    else {
        budgetRatio = 1 - [[budgetLeft decimalNumberByDividingBy: monthlyBudget] floatValue];
    }

    // indicates color
    [self.budgetLeftProgress setTrackTintColor:[UIColor whiteColor]];
    if( budgetRatio >= 0.75) {
        [self.budgetLeftProgress setProgressTintColor: UIColorFromHex(0xEE4000)];
    }
    else if ( budgetRatio >= 0.5 ) {
        [self.budgetLeftProgress setProgressTintColor: UIColorFromHex(0xFFD700)];
    }
    else {
        [self.budgetLeftProgress setProgressTintColor: UIColorFromHex(0xADFF2F)];
    }
    
    [self.budgetLeftProgress setProgress: budgetRatio animated:YES];

    // get category array
    self.categoryArray = [CategoryModel getCategories:self.context];
    
    // budget label
    NSNumber *amountNumber = [[NSNumber alloc]initWithFloat:fabs(totalAmount.floatValue)];
    
    self.totalAmountLabel.text =
        [NSNumberFormatter localizedStringFromNumber:amountNumber numberStyle:NSNumberFormatterCurrencyStyle];
    
    if( [monthlyBudget compare:[NSDecimalNumber zero]] == NSOrderedSame ) {
        self.budgetLeftLabel.text =
            [[NSString alloc]initWithFormat: @"Set Monthly\nBudget"];
        self.budgetLeftLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *emptyBudgetLabelTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(emptyBudgetTouchUpInside:)];
        [self.budgetLeftLabel addGestureRecognizer:emptyBudgetLabelTapGestureRecognizer];
    }
    else {
        self.budgetLeftLabel.text =
            [[NSString alloc]initWithFormat: @"Budget Left:\n%@",
             [NSNumberFormatter localizedStringFromNumber:budgetLeft numberStyle:NSNumberFormatterCurrencyStyle]];
    }

    // Summary label
    [self.typeLabel setText: self.choosedReportViewType];
    [self.amountLabel setText: [NSNumberFormatter localizedStringFromNumber:totalAmount numberStyle:NSNumberFormatterCurrencyStyle] ];
    
    self.summaryView.userInteractionEnabled = YES;
    UITapGestureRecognizer *summaryLabelTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(summaryLabelTouchUpInside:)];
    [self.summaryView addGestureRecognizer:summaryLabelTapGestureRecognizer];
    
    // Exchange label
    [self.exchangeLabel setText: @"\U0000F0EC"];
    [self.exchangeLabel setTextColor: UIColor.orangeColor];
    [self.exchangeLabel setFont: [UIFont fontWithName:@"FontAwesome" size:14]];
}

- (void)viewWillAppear:(BOOL)animated {
    //[self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
    
    [self refreshView];
}

- (void)refreshView {
    [self loadViewData];
    [self.segmentedControl sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)viewWillDisappear:(BOOL)animated {
    //[self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) emptyBudgetTouchUpInside:(UITapGestureRecognizer *)recognizer {
    SettingViewController *settingViewController =
        [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"setting"];
    [settingViewController showBudgetSettingAlert:self successHandler:^{
        [self refreshView];
    }];
}

- (void) labelTouchUpInside:(UITapGestureRecognizer *)recognizer{
    //UILabel *label = (UILabel*)recognizer.view;
    [self datePickerViewToggle:NO];
}

- (void) summaryLabelTouchUpInside:(UITapGestureRecognizer *)recognizer{
    if( [self.choosedReportViewType isEqualToString: @"Expenses"] ) {
        self.choosedReportViewType = @"Income";
        self.exchangeLabel.textColor = UIColorFromHex(0x1b926c);
    }
    else {
        self.choosedReportViewType = @"Expenses";
        self.exchangeLabel.textColor = UIColor.orangeColor;
    }
    
    NSDecimalNumber *sumAmount =
    [AccountingModel sumOfAccountingAmounts:self.context typeFilter:self.choosedReportViewType
                                  beginDate:self.beginDate endDate:self.endDate];
    
    [self.typeLabel setText: self.choosedReportViewType];
    [self.amountLabel setText: [NSNumberFormatter localizedStringFromNumber:sumAmount numberStyle:NSNumberFormatterCurrencyStyle]];

    [self loadReportViewByCategoryType: self.choosedReportViewType];
}

- (IBAction)hideDatePickerView:(id)sender {
    [self datePickerViewToggle:YES];
}

- (IBAction)confirmDateInPickerView:(id)sender {
    [self setDateAndDateLabel: [self.datePickerDelegate getSelectedDate] mode:self.datePickerDelegate.selectedMode];
    [self datePickerViewToggle:YES];
    [self refreshView];
}

- (void)datePickerViewToggle:(BOOL)hidden {
    if(!hidden) {
        self.datePickerContentView.alpha = 0;
        self.datePickerContentView.hidden = NO;
        [UIView animateWithDuration:.6 animations:^{
            self.datePickerContentView.alpha = 1;
        } completion:^(BOOL finished) {
        }];
    }
    else {
        self.datePickerContentView.alpha = 1;
        [UIView animateWithDuration:.6 animations:^{
            self.datePickerContentView.alpha = 0;
        } completion:^(BOOL finished) {
            self.datePickerContentView.hidden = YES;
        }];
    }
}

- (IBAction)chargeUpTouchUp:(id)sender {
    KeepAccountsViewController *keepAccountsViewController = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"keep-accounts"];
    [self.navigationController showViewController:keepAccountsViewController sender:nil];
}

- (IBAction)segmentedValueChanged:(UISegmentedControl *)sender {
    
    switch(sender.selectedSegmentIndex) {
        case 0: {
            [self changeDetailView];
            break;
        }
        case 1: {
            [self loadReportViewByCategoryType: self.choosedReportViewType];
            break;
        }
        default: {
            // DO nothing
            break;
        }
    }
}

- (void)changeDetailView {
    // set pie view hide
    [self.pieViewHeightConstraint setActive:false];
    self.pieViewHeightConstraint = [self.pieView.heightAnchor constraintEqualToConstant:0];
    [self.pieViewHeightConstraint setActive:true];
    [self.pieView setHidden:YES];
    
    // refresh data
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.transactionDelegate
            refreshDataFromDatabase:self.transactionTableView
                          beginDate:self.beginDate endDate:self.endDate
                    refreshFunction:^{
                            [self.transactionDelegate classifyDataByDateFormat:@"yyyy-MM-dd (EEE)"];
                    }
         ];
    });
}

- (void)loadReportViewByCategoryType:(NSString *)type {
    // Set pie view
    
    // init
    CGFloat W = 220, reality_H = 250;
    
    // remove all sub views
    for (UIView *subview in self.pieView.subviews) {
        Boolean isAbleToRemove = YES;
        if ([subview isKindOfClass:[UIView class]]) {
            UILabel *key = (UILabel *)subview;
            NSString *ident = key.restorationIdentifier;
            if( [ident isEqualToString:@"summaryView"] ) {
                isAbleToRemove = NO;
            }
        }
        
        if( isAbleToRemove ) {
            [subview removeFromSuperview];
        }
    }
    
    // show
    [self.pieViewHeightConstraint setActive:false];
    self.pieViewHeightConstraint = [self.pieView.heightAnchor constraintEqualToConstant:reality_H];
    [self.pieViewHeightConstraint setActive:true];
    [self.pieView setNeedsLayout];
    [self.pieView layoutIfNeeded];
    [self.pieView setHidden:NO];
    
    // refresh data
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.transactionDelegate
            refreshDataFromDatabase:self.transactionTableView
                          beginDate:self.beginDate endDate:self.endDate
                    refreshFunction:^{
                        [self.transactionDelegate classifyDataByCategoryType: type];
                    }
        ];
        
        RMSPieView *pieView =
            [[RMSPieView alloc]initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - W) / 2, (reality_H - W) / 2, W, W)];
        [self.pieView addSubview:pieView];
        
        NSDictionary *pieDatas = [self getPieDataByCategoryType:type];
        
        // blank view
        NSLog(@"[pieDatas count]: %lu", (unsigned long)[pieDatas count]);
        if( ![pieDatas[@"amounts"] count] ) {
            NSMutableDictionary *tmpPieData = [[NSMutableDictionary alloc]init];
            [tmpPieData setObject:[[NSMutableArray alloc]init] forKey:@"amounts"];
            [tmpPieData setObject:[[NSMutableArray alloc]init] forKey:@"colors"];
            [tmpPieData[@"amounts"] addObject: [[NSNumber alloc]initWithInt:1]];
            [tmpPieData[@"colors"]  addObject: UIColor.grayColor];
            pieDatas = tmpPieData;
            
            //self.typeLabel.text = @"";
            //self.amountLabel.text = @"You haven't made\nany note yet.";
            //self.amountLabel.numberOfLines = 2;
        }

        [pieView setDatas: pieDatas[@"amounts"] colors: pieDatas[@"colors"]];
        [pieView stroke];
        
        [self.pieView bringSubviewToFront:self.summaryView];
    });
}


- (void)checkFont {
    // check font
    for (NSString* family in [UIFont familyNames]) {
        NSLog(@"%@", family);
        for (NSString* name in [UIFont fontNamesForFamilyName: family]) {
            NSLog(@"  %@", name);
        }
    }
}
    
// pass a param to describe the state change, an animated flag and a completion block matching UIView animations completion
- (void)setTabBarVisible:(BOOL)visible animated:(BOOL)animated completion:(void (^)(BOOL))completion {
    
    // bail if the current state matches the desired state
    if ([self tabBarIsVisible] == visible) return (completion)? completion(YES) : nil;
    
    // get a frame calculation ready
    CGRect frame = self.tabBarController.tabBar.frame;
    CGFloat height = frame.size.height;
    CGFloat offsetY = (visible)? -height : height;
    
    // zero duration means no animation
    CGFloat duration = (animated)? 0.3 : 0.0;
    
    [UIView animateWithDuration:duration animations:^{
        self.tabBarController.tabBar.frame = CGRectOffset(frame, 0, offsetY);
    } completion:completion];
}

//Getter to know the current state
- (BOOL)tabBarIsVisible {
    return self.tabBarController.tabBar.frame.origin.y < CGRectGetMaxY(self.view.frame);
}

/*
#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender { }
*/

@end
