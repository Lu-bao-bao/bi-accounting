//
//  KeepAccountsViewController.m
//  Accounting
//
//  Created by AmeRin on 17/11/2017.
//  Copyright © 2017 RM studio. All rights reserved.
//

#import "KeepAccountsViewController.h"
#import "NoteViewController.h"
#import "TagViewController.h"

#import "AppDelegate.h"

#import "Category+CoreDataClass.h"
#import "Category+CoreDataProperties.h"

#import "AccountingModel.h"
#import "CategoryModel.h"

#import "CALayer+Addition.h"
#import "UIControl+UIButton.h"

#import "NumberPad.h"
#import "Utils.h"

@interface KeepAccountsViewController ()

@property (nonatomic,strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSArray *categoryArray;
@property (nonatomic, strong) NumberPad *numberPad;
@property (nonatomic, strong) UIButton *selectedButton;
@property (nonatomic, strong) UIButton *titleButton;
@property (nonatomic, strong) NSString *selectedCategory;

@end

@implementation KeepAccountsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Load context.
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.context = delegate.persistentContainer.viewContext;
    
    // Load Data
    self.selectedCategory = @"Expenses";
    self.categoryArray = [CategoryModel getCategoriesByType:self.selectedCategory context:self.context];
    self.numberPad = [[NumberPad alloc] init];
    
    // Init base data.
    if(self.accountingDate == nil) {
        self.accountingDate = [NSDate date];
    }
    
    self.formatter = [[NSDateFormatter alloc] init];
    [self.formatter setDateFormat:@"MMM dd, yyyy"];
    
    // Load view
    [[NSBundle mainBundle] loadNibNamed:@"KeepAccountsViewController" owner:self options:nil];
    
    [self loadStaticView];
}

- (void)viewWillAppear:(BOOL)animated {
    // Load view
    [self loadView];
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

- (void)loadStaticView {
    // Title button
    self.titleButton = [UIButton buttonWithType:(UIButtonTypeRoundedRect)];
    self.navigationItem.titleView = self.titleButton;
    
    [self.titleButton.titleLabel setFont: [UIFont boldSystemFontOfSize:16]];
    [self.titleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    // Datepicker view
    [self.view addSubview:self.datePickerView];
    
    NSLayoutConstraint *datePickerBottomAnchor =
        [self.datePickerView.bottomAnchor constraintEqualToAnchor: self.view.bottomAnchor];
    NSLayoutConstraint *datePickerTrailingAnchorAnchor =
        [self.datePickerView.trailingAnchor constraintEqualToAnchor: self.view.trailingAnchor];
    NSLayoutConstraint *datePickerLeadingAnchorAnchorAnchor =
        [self.datePickerView.leadingAnchor constraintEqualToAnchor: self.view.leadingAnchor];
    [NSLayoutConstraint activateConstraints:
        @[datePickerBottomAnchor, datePickerTrailingAnchorAnchor, datePickerLeadingAnchorAnchorAnchor]];
    
    // Date button gesture
    UITapGestureRecognizer *dateButtonTapGestureRecognizer =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dateTouchUp:)];
    [self.dateButton addGestureRecognizer:dateButtonTapGestureRecognizer];

    // Disable gesture
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)loadView {
    // TO-DO: setup animate
    // ...
    
    // load default amount and abs it.
    if(self.accountingAmount != nil) {
        [self.numberPad setNumberPad:[[Utils decimalNumberAbs:self.accountingAmount] stringValue]];
        self.digitBoard.text = [NSString stringWithFormat:@"%@ %@", @"$", [self.numberPad getNumberPad]];
    }

    // scroll view delegate
    self.scrollView.delegate = self;
    
    // category title
    if( [self.accountingCategory isEqualToString:@""] || self.accountingCategory == nil) {
        [self.titleButton setTitle:[[NSString alloc]initWithFormat:@"Charge Up"] forState:(UIControlStateNormal)];
    }
    else {
        [self.titleButton setTitle:[[NSString alloc]initWithFormat:@"%@ %@", self.categoryIcon ? self.categoryIcon : @"", self.accountingCategory] forState:(UIControlStateNormal)];
    }
    [self.titleButton sizeToFit];
    
    // load message board
    [self loadDateButtonView];

    // delete button
    [self.backspaceButton setImage:[UIImage imageNamed:@"backspace"] forState:UIControlStateNormal];
    self.backspaceButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.backspaceButton.imageEdgeInsets = UIEdgeInsetsMake(20, 20, 20, 20);
    
    // bar button
    [self.noteBarButton setImageInsets:UIEdgeInsetsMake(0, 10, 0, -10)];
    [self.tagsBarButton setImageInsets:UIEdgeInsetsMake(0, 25, 0, -25)];
    
    // note button
    if( [self.accountingComment length] ) {
        self.noteButton.layer.borderColor = UIColor.redColor.CGColor;
        [self.noteBarButton setImage:[UIImage imageNamed:@"full-note"]];
    }
    else {
        self.noteButton.layer.borderColor = UIColor.grayColor.CGColor;
        [self.noteBarButton setImage:[UIImage imageNamed:@"empty-note"]];
    }

    // load category
    [self loadCategory];
}

- (void)loadDateButtonView {
    // date picker
    NSString * dateString = [self.formatter stringFromDate:self.accountingDate];
    [self.datePickerButton setTitle:dateString forState:UIControlStateNormal];
    self.datePicker.backgroundColor = UIColor.whiteColor;
    
    // message board
    [self.dateButton setTitle: [[NSString alloc]initWithFormat:@"📅 %@ ▼", dateString] forState: UIControlStateNormal];
    
    if(UI_IS_IPHONE5_S_E) {
        self.dateButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    }
}

- (void)loadCategory {
    // init
    NSUInteger V = 3, subH = 5;
    // button 50 -> spacing 20, button 60 -> spacing 10
    NSUInteger spacing = 10;
    UIStackView *verticalStackView;
    UIStackView *horizontalStackView;
    
    if(UI_IS_IPHONE5_S_E) {
        V = 2;
        [self.scrollView.heightAnchor constraintEqualToConstant:120].active = YES;
        
        CGRect frame = self.scrollView.frame;
        frame.size.height = 120;
        self.scrollView.frame = frame;
    }
    
    // page control init
    self.pageControl.numberOfPages = [self.categoryArray count] / (V * subH) + 1;
    [self.pageControl sizeForNumberOfPages: 1];
    
    // remove all sub views
    for (UIView *subview in self.scrollView.subviews) {
        [subview removeFromSuperview];
    }
    
    // load category loop
    NSMutableArray *currentStackView = [[NSMutableArray alloc]init];
    NSMutableArray *currentButtons = [[NSMutableArray alloc]init];
    
    for( NSUInteger index = 0; index <= [self.categoryArray count]; index++ )
    {
        if( !(index % (V*subH)) ) {
            // new vertical stackview
            verticalStackView =
                [[UIStackView alloc] initWithFrame:CGRectMake( (index/(V*subH))*[UIScreen mainScreen].bounds.size.width, 0, [UIScreen mainScreen].bounds.size.width, self.scrollView.frame.size.height)];
            verticalStackView.axis = UILayoutConstraintAxisVertical;
            verticalStackView.alignment = UIStackViewAlignmentCenter;
            verticalStackView.distribution = UIStackViewDistributionFillEqually;

            self.scrollView.contentSize = CGSizeMake((index/(V*subH)+1)*[UIScreen mainScreen].bounds.size.width, self.scrollView.frame.size.height);
            [self.scrollView addSubview:verticalStackView];
            
            for( int i = 0; i < V; i ++ ) {
                horizontalStackView = [[UIStackView alloc] init];
                horizontalStackView.axis = UILayoutConstraintAxisHorizontal;
                horizontalStackView.alignment = UIStackViewAlignmentFill;
                horizontalStackView.distribution = UIStackViewDistributionFillEqually;
                horizontalStackView.spacing = spacing;
                
                [verticalStackView addArrangedSubview:horizontalStackView];
                [currentStackView addObject:horizontalStackView];
                
                for( int j = 0; j < subH; j++ ) {
                    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                    [horizontalStackView addArrangedSubview:button];
                    [currentButtons addObject:button];
                }
            }
        }
        
        if( [self.categoryArray count] == index ) {
            UIButton *button = [currentButtons objectAtIndex:index];
            [self storeDataToButton: button categoryName:@"New" categoryIcon:@"➕"];
            [button removeTarget:self action:@selector(categoryTouchUp:) forControlEvents: UIControlEventTouchUpInside];
            [button addTarget:self action:@selector(addCategoryTouchUp:) forControlEvents: UIControlEventTouchUpInside];
        }
        else {
            Category *category = [self.categoryArray objectAtIndex:index];
            [self storeDataToButton:[currentButtons objectAtIndex:index] categoryName:category.name categoryIcon:category.icon];
        }
    }
}

- (void)storeDataToButton:(UIButton *)button categoryName:(NSString *)name categoryIcon:(NSString *)icon {
    NSMutableAttributedString *attrString =
    [[NSMutableAttributedString alloc] initWithString: [[NSString alloc] initWithFormat:@"%@\n%@", icon, name] ];
    [attrString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:20.0f] range:NSMakeRange(0, 2)];
    [attrString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:9.0f] range:NSMakeRange(2, [attrString length]-2)];
    [attrString addAttribute:NSForegroundColorAttributeName
                       value:[UIColor blackColor]
                       range:NSMakeRange(0, [attrString length])];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:3.0];
    [paragraphStyle setAlignment: NSTextAlignmentCenter];
    [attrString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [attrString length])];

    button.titleLabel.lineBreakMode = 0;
    button.titleLabel.numberOfLines = 2;
    [button setCategoryName: name];
    [button setAttributedTitle:attrString forState:UIControlStateNormal];
    [button setTitleColor:UIColor.blackColor forState: UIControlStateNormal];
    [button.titleLabel setTextAlignment:NSTextAlignmentCenter];
    
    // Fuck: It's no use in UIStackView
    //button.frame = CGRectMake(0, 0, 50, 50);
    [button.widthAnchor constraintEqualToConstant:60].active = true;
    button.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 5);
   
    [button addTarget:self action:@selector(categoryTouchUp:) forControlEvents: UIControlEventTouchUpInside];
}

- (IBAction)segmentedValueChanged:(UISegmentedControl *)sender {
    NSLog(@"keep Accounts sender.selectedSegmentIndex: %ld", (long)sender.selectedSegmentIndex);
    
    switch(sender.selectedSegmentIndex) {
        case 0: {
            self.selectedCategory = @"Expenses";
            break;
        }
        case 1: {
            self.selectedCategory = @"Income";
            break;
        }
        default: {
            // DO nothing
            break;
        }
    }
    
    self.categoryArray = [CategoryModel getCategoriesByType:self.selectedCategory context:self.context];
    [self loadCategory];
}

- (IBAction)keyboardTouchUp:(UIButton *)button {
    if( [button.titleLabel.text isEqualToString: @"."] ) {
        [self.numberPad appendDot];
        self.digitBoard.text = [NSString stringWithFormat:@"%@ %@", @"$", [self.numberPad getNumberPad]];
    }
    else if([button.titleLabel.text isEqualToString: @"⌫"]) {
        // '<', backspace
        [self.numberPad attachBackspace];
        self.digitBoard.text = [NSString stringWithFormat:@"%@ %@", @"$", [self.numberPad getNumberPad]];
    }
    else if([Utils isPureInt:button.titleLabel.text]) {
        [self.numberPad appendDigit: [button.titleLabel.text characterAtIndex:0]];
        self.digitBoard.text = [NSString stringWithFormat:@"%@ %@", @"$", [self.numberPad getNumberPad]];
    }
    
    self.accountingAmount = [[NSDecimalNumber alloc]initWithString:[self.numberPad getNumberPad]];
}

- (IBAction)dateTouchUp:(id)sender {
    [self datePickerViewToggle: NO];
}

- (IBAction)datePickerCancel:(id)sender {
    [self datePickerViewToggle: YES];
}

- (IBAction)datePickerConfirm:(id)sender {
    self.accountingDate = self.datePicker.date;
    NSString * dateString = [self.formatter stringFromDate:self.accountingDate];
    
    // set button
    [self.datePickerButton setTitle:dateString forState:UIControlStateNormal];
    
    // set title
    [self loadDateButtonView];

    [self datePickerViewToggle: YES];
}

- (void)datePickerViewToggle:(BOOL)hidden {
    if(!hidden) {
        self.datePickerView.alpha = 0;
        self.datePickerView.hidden = NO;
        [UIView animateWithDuration:.6 animations:^{
            self.datePickerView.alpha = 1;
        } completion:^(BOOL finished) {
}];
    }
    else {
        self.datePickerView.alpha = 1;
        [UIView animateWithDuration:.6 animations:^{
            self.datePickerView.alpha = 0;
        } completion:^(BOOL finished) {
            self.datePickerView.hidden = YES;
        }];
    }
}

- (void)categoryTouchUp: (UIButton*)button {
    // checked style
    if( self.selectedButton ) {
        self.selectedButton.layer.borderWidth = 0;
    }
    button.layer.borderWidth = 3;
    button.layer.borderColor = UIColorFromHex(0x008B8B).CGColor;
    button.layer.cornerRadius = 10;

    // data
    self.selectedButton = button;
    self.accountingCategory = button.categoryName;
    self.categoryIcon = [CategoryModel getCategoryIconByName:self.accountingCategory context:self.context];
    
    [self.titleButton setTitle:[[NSString alloc]initWithFormat:@"%@ %@", self.categoryIcon, self.accountingCategory] forState:(UIControlStateNormal)];
    [self.titleButton sizeToFit];
}

- (void)addCategoryTouchUp: (UIButton*)button {
    [self categoryAppendDialog];
}

- (IBAction)appendAccountNote:(id)sender {
    // jump
    NoteViewController *noteController = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"account-note"];
    noteController.accountingComment = self.accountingComment;
    [self.navigationController showViewController:noteController sender:nil];
}

- (IBAction)appendAccountTags:(id)sender {
    // jump
    TagViewController *tagController = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"account-tags"];
    tagController.selectedTags = self.selectedTags;
    [self.navigationController showViewController:tagController sender:nil];
}

#pragma mark Scroll view delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    int page = (scrollView.contentOffset.x) / scrollView.frame.size.width;
    self.pageControl.currentPage = page;
    
}

- (IBAction)chargeUpSliderValueChanged:(UISlider *)confirmSlider {
    if( confirmSlider.value == 1 ) {
        [confirmSlider setEnabled: NO];
        Boolean clearNumpad = NO;

        if( [Utils isPureInt: [self.numberPad getNumberPad]] || [Utils isPureFloat: [self.numberPad getNumberPad]] )
        {
            NSDecimalNumber *amount = [NSDecimalNumber decimalNumberWithString: [self.numberPad getNumberPad]];
            
            if( [amount compare: [NSNumber numberWithInt:0]] == NSOrderedSame ) {
                [self.digitBoard setText:@"$ 0"];
                [self showSliderError:confirmSlider title:@"Amount cannot be zero"];
            }
            else if( self.accountingCategory == nil || [self.accountingCategory isEqualToString:@""] ) {
                [self showSliderError:confirmSlider title:@"Please select a category first"];
            }
            else {
                // Save context start.
                
                [CategoryModel transAmountViaCategoryType:&amount categoryName:self.accountingCategory context:self.context];
                [AccountingModel
                 updateAccounting:self.context objectId:self.accountingId amount:amount category:self.accountingCategory
                 tags:[self.selectedTags componentsJoinedByString: @","] comment:self.accountingComment createTime: self.accountingDate
                 successHandler:^{
                     NSString *title = @"Transaction saved";
                     NSString *description = nil;
                     
                     UIAlertController *alertDialog =
                     [UIAlertController alertControllerWithTitle:title message:description preferredStyle:UIAlertControllerStyleAlert];

                     [self presentViewController:alertDialog animated:YES completion:nil];
                     [self performSelector:@selector(dismiss:) withObject:alertDialog afterDelay:1.5];
                 } errorHandler:^(NSError *error) {
                     NSLog(@"%@", [NSString stringWithFormat:@"Charge up controller :Found core data error: %@", [error localizedDescription]]);
                 }];
                
                // clear number pad.
                clearNumpad = YES;
            }
        }
        else {
            [self showSliderError: confirmSlider title: nil];
            clearNumpad = YES;
        }
        
        // clear number pad.
        if(clearNumpad) [self.numberPad clear];
    }
}

- (void)showSliderError:(UISlider *)confirmSlider title:(NSString *)title {
    // clear slider
    [confirmSlider setEnabled:YES];
    [confirmSlider setValue:0];
    
    // show alert dialog
    if( title == nil || [title isEqualToString:@""] )
        title = @"Wrong Input";
    NSString *description = nil;
    
    UIAlertController *alertDialog =
        [UIAlertController alertControllerWithTitle:title message:description preferredStyle:UIAlertControllerStyleAlert];
    
    [self presentViewController:alertDialog animated:YES completion:nil];
    [self performSelector:@selector(showWarning:) withObject:alertDialog afterDelay:1.5];
}

- (void)dismiss:(UIAlertController *)alertController {
    [alertController dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showWarning:(UIAlertController *)alertController {
    [alertController dismissViewControllerAnimated:YES completion:nil];
}


- (void)categoryAppendDialog {
    
    NSString *alertTitle = @"New category";

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle message:@"Please input the content" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *confirmAction =
    [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [CategoryModel appendCategory:self.context
                                 name:alertController.textFields.firstObject.text
                                 icon:alertController.textFields.lastObject.text
                                alias:@""
                                 type:self.selectedCategory
                             sequence:-1];
        
        self.categoryArray = [CategoryModel getCategoriesByType:self.selectedCategory context:self.context];
        [self loadCategory];
    }];

    [alertController addAction:confirmAction];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil]];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Name";
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Emoji Icon";
        textField.text = @"💰";
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        [textField addTarget:self action:@selector(textFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
    }];
    
    [self presentViewController:alertController animated:true completion:nil];
}

- (void)textFieldEditingChanged:(UITextField *)textField
{
    if( ![Utils stringContainsEmoji:textField.text] ) {
        textField.text = @"";
    }
    if( [textField.text length] > 2 ) {
        textField.text = [textField.text substringToIndex: 2];
    }
}

@end
