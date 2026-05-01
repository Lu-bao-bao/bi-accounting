//
//  TodayViewController.m
//  AccountingToday
//
//  Created by AmeRin on 14/10/2017.
//  Copyright © 2017 RM studio. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>

#import "Accounting+CoreDataClass.h"
#import "Accounting+CoreDataProperties.h"
#import "Category+CoreDataClass.h"
#import "Category+CoreDataProperties.h"

#import "BaseModel.h"
#import "AccountingModel.h"
#import "CategoryModel.h"
#import "Utils.h"
#import "NumberPad.h"

#import "UIControl+UIButton.h"

@interface TodayViewController () <NCWidgetProviding>
@property (nonatomic, strong) UILabel *digitalBoard;
@property (nonatomic, strong) UILabel *showHomeLabel;
@property (nonatomic, strong) UIView *compactView;
@property (nonatomic, strong) UIScrollView *categoryView;
@property (nonatomic, strong) UIView *digitalView;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSMutableArray *categoryData;
@property (nonatomic, assign) CGFloat todayViewHeight;
@property (nonatomic, strong) NumberPad * numberPad;
@end

@implementation TodayViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // widget display mode
    self.extensionContext.widgetLargestAvailableDisplayMode = NCWidgetDisplayModeExpanded;
}

// If implemented, called when the active display mode changes.
// The widget may wish to change its preferredContentSize to better accommodate the new display mode.
- (void)widgetActiveDisplayModeDidChange:(NCWidgetDisplayMode)activeDisplayMode withMaximumSize:(CGSize)maxSize {
    if (activeDisplayMode == NCWidgetDisplayModeCompact) {
        self.digitalView.hidden = YES;
        self.categoryView.hidden = YES;
        self.compactView.hidden = NO;
        self.preferredContentSize = CGSizeMake(maxSize.width, 110);
    } else {
        self.digitalView.hidden = NO;
        self.categoryView.hidden = NO;
        self.compactView.hidden = YES;
        self.preferredContentSize = CGSizeMake(maxSize.width, self.todayViewHeight);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // init
    self.categoryData = [NSMutableArray array];
    if( UI_IS_IPHONE5_S_E ) {
        self.todayViewHeight = 230;
    }
    else {
        self.todayViewHeight = 260;
    }
    
    self.numberPad = [[NumberPad alloc] init];

    // load database
    self.context = [BaseModel setupCoreDataStackWithStoreNamed:@"Model"];
    [self getCategoriesFromDatabase];
    
    // load main view
    [self loadMainView];
}

- (void)loadMainView {
    // Views
    CGFloat digitViewRatio = .55;
    CGFloat W = 50, H = 50, top = 10, left = 10;
    
    if( UI_IS_IPHONE5_S_E ) {
        W = 40; H = 40;
    }
    
    /* Compact View */
    self.compactView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 110)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 30, self.compactView.frame.size.width-20, 40)];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 2;
    label.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.6];
    [label setText: @"Click 'Show More' To Keep Accounts\nClick Me To Show Bi Home."];
    [label setFont: [UIFont systemFontOfSize:16.0]];
    UITapGestureRecognizer *labelTapGestureRecognizer =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelTouchUpInside:)];
    label.userInteractionEnabled = YES;
    [label addGestureRecognizer:labelTapGestureRecognizer];
    [self.compactView addSubview:label];

    NSLayoutConstraint* centerXConstraint = [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.compactView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f];
    NSLayoutConstraint* centerYConstraint = [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.compactView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f];
    [self.compactView addConstraints: @[centerXConstraint, centerYConstraint]];
    
    self.compactView.hidden = YES;
    [self.view addSubview:self.compactView];
    
    
    /* Digital View */
    self.digitalView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width * digitViewRatio, self.todayViewHeight)];

    // Label view.
    self.digitalBoard = [[UILabel alloc] initWithFrame:CGRectMake(left, top, self.digitalView.frame.size.width, H - 10)];
    self.digitalBoard.layer.cornerRadius = 15;
    self.digitalBoard.layer.masksToBounds = YES;
    [self.digitalBoard setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.3]];
    [self.digitalBoard setText:@"$ 0"];
    [self.digitalBoard setFont:[UIFont systemFontOfSize: 18]];
    [self.digitalBoard setTextAlignment:NSTextAlignmentCenter];
    [self.digitalView addSubview:self.digitalBoard];
    
    // Digital button view.
    top = top + 50;
    NSInteger rank = 4;
    CGFloat rowMargin = 10, rankMargin = (self.digitalView.frame.size.width - rank * W) / (rank - 1);
    NSArray *keyPad = [NSArray arrayWithObjects:
                       @"1", @"2", @"3", @"C",
                       @"4", @"5", @"6", @".",
                       @"7", @"8", @"9", @"0", nil];

    for (int i = 0; i < [keyPad count]; i++) {
        CGFloat X = (i % rank) * (W + rankMargin);
        NSUInteger Y = (i / rank) * (H + rowMargin);
        
        if( ![[keyPad objectAtIndex:i] isEqualToString:@"?"] ) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            button.frame = CGRectMake(X+left, Y+top, W, H);
            button.layer.cornerRadius = W/2.0;
            button.layer.masksToBounds = YES;
            [button setTitle:[keyPad objectAtIndex:i] forState:UIControlStateNormal];
            [button setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.3]];
            [button setTitleColor:[UIColor blackColor] forState:(UIControlState)UIControlStateNormal];
            [button addTarget:self action:@selector(digitalPadTouchUp:) forControlEvents: UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
            [self.digitalView addSubview:button];
        }
    }
    
    // add to main view.
    [self.view addSubview:self.digitalView];

    
    /* Category View */
    W = self.view.frame.size.width * (1-digitViewRatio) - 50; H = 38; top = 10; left = 10;
    rowMargin = 7;
    NSInteger itemLimit = 5;
    
    if( UI_IS_IPHONE5_S_E ) {
        H = 32;
    }
    
    self.categoryView = [[UIScrollView alloc] initWithFrame:
        CGRectMake(self.view.frame.size.width * digitViewRatio, 0, self.view.frame.size.width * (1-digitViewRatio), self.todayViewHeight)];
    self.categoryView.scrollEnabled = YES;
    self.categoryView.pagingEnabled = YES;
    //self.categoryView.contentOffset = CGPointMake(0, 150);
    self.categoryView.contentSize = CGSizeMake(self.view.frame.size.width * (1-digitViewRatio), 1000);
    
    UIView *categoryInnerFrame = [[UIView alloc] initWithFrame:
        CGRectMake(0, 0, self.view.frame.size.width * (1-digitViewRatio), 1000)];
    
    NSUInteger i = 0;
    for(Category *category in self.categoryData)
    {
        CGFloat X = 10;
        NSUInteger Y = i++ * (H + rowMargin);
    
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        button.frame = CGRectMake(X+left, Y+top, W, H);
        button.layer.cornerRadius = 15;
        button.layer.masksToBounds = YES;
        button.titleLabel.adjustsFontSizeToFitWidth = YES;
        button.categoryName = category.name;
        [button setTitle: [[NSString alloc] initWithFormat:@"%@ %@", category.icon, category.name] forState:UIControlStateNormal];
        [button setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.3]];
        [button setTitleColor:[UIColor blackColor] forState:(UIControlState)UIControlStateNormal];
        [button addTarget:self action:@selector(categoryTouchUp:) forControlEvents: UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
        [categoryInnerFrame addSubview:button];
        
        NSLog(@"category.name: %@", category.name);
        
        if( i >= itemLimit ) break;
    }
    [self.categoryView addSubview:categoryInnerFrame];
    
    // add to main view.
    [self.view addSubview:self.categoryView];
    
    
    /* Show home label */
    self.showHomeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, self.todayViewHeight-23, self.view.frame.size.width, 20)];
    [self.showHomeLabel setText:@"Show Home >"];
    [self.showHomeLabel setTextColor: [UIColor darkGrayColor]];
    [self.showHomeLabel setFont:[UIFont systemFontOfSize: 12]];
    self.showHomeLabel.userInteractionEnabled = YES;
    labelTapGestureRecognizer =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelTouchUpInside:)];
    [self.showHomeLabel addGestureRecognizer:labelTapGestureRecognizer];

    [self.view addSubview:self.showHomeLabel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    completionHandler(NCUpdateResultNewData);
}

- (void)getCategoriesFromDatabase {
    NSArray *fetchedObjects = [CategoryModel getCategories:self.context];
    if( fetchedObjects == nil ) {
        NSLog(@"Nothing fetched.");
    }
    else {
        // append data.
        [self.categoryData removeAllObjects];
        [self.categoryData addObjectsFromArray:fetchedObjects];
    }
}

- (void)labelTouchUpInside:(UITapGestureRecognizer *)recognizer {
    NSLog(@"Some one clicked me.");
    NSURL *url = [NSURL URLWithString:@"accounting://"];
    [self.extensionContext openURL:url completionHandler:nil];
}

- (void)digitalPadTouchUp: (UIButton*)button {

    NSArray *input = [NSArray arrayWithObjects: @".", @"<", @"C", @"OK", nil];
    switch( [input indexOfObject: button.titleLabel.text] ) {
        case 0:
            // '.', dot
            [self.numberPad appendDot];
            self.digitalBoard.text = [NSString stringWithFormat:@"$ %@", [self.numberPad getNumberPad]];
            break;
        case 1:
            // '<', backspace
            [self.numberPad attachBackspace];
            self.digitalBoard.text = [NSString stringWithFormat:@"$ %@", [self.numberPad getNumberPad]];
            break;
        case 2:
            // 'C', all clear
            [self.numberPad clear];
            self.digitalBoard.text = [NSString stringWithFormat:@"$ %@", [self.numberPad getNumberPad]];
            break;
        case 3:
            // When 'OK' is clicked.
            // Save context.
            break;
        default:
            // other digits
            [self.numberPad appendDigit: [button.titleLabel.text characterAtIndex:0]];
            self.digitalBoard.text = [NSString stringWithFormat:@"$ %@", [self.numberPad getNumberPad]];
            break;
    }
}

- (void)categoryTouchUp: (UIButton*)button {
    // Save context.
    
    if( [Utils isPureInt: [self.numberPad getNumberPad]] || [Utils isPureFloat: [self.numberPad getNumberPad]] )
    {
        NSDecimalNumber *amount = [NSDecimalNumber decimalNumberWithString: [self.numberPad getNumberPad]];

        if( [amount compare: [NSNumber numberWithInt:0]] == NSOrderedSame ) {
            [self.digitalBoard setText:@"$ 0"];
        }
        else {
            [CategoryModel transAmountViaCategoryType:&amount categoryName:button.categoryName context:self.context];
            [AccountingModel createAccounting:self.context amount:amount category:button.categoryName
                                         tags:nil comment:button.categoryName createTime:[NSDate date]
                               successHandler:^{
                    NSString *categoryType = [CategoryModel getCategoryByName: button.categoryName context:self.context].type;
                    [self.digitalBoard setText: [[NSString alloc] initWithFormat:@"✅ %@ Saved", categoryType]];
            } errorHandler:^(NSError *error){}];
        }
    }
    else {
        [self.digitalBoard setText:@"🚫 Error"];
    }
    
    // clear number pad.
    [self.numberPad clear];
}

@end
