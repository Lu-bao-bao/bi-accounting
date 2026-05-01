//
//  TransactionDelegate.m
//  Accounting
//
//  Created by AmeRin on 16/11/2017.
//  Copyright © 2017 RM studio. All rights reserved.
//

#import "TransactionDelegate.h"
#import "TransactionTableViewCell.h"
#import "EmptyInfoTableViewCell.h"

#import "Accounting+CoreDataClass.h"
#import "Accounting+CoreDataProperties.h"
#import "Category+CoreDataClass.h"
#import "Category+CoreDataProperties.h"

#import "AccountingModel.h"
#import "CategoryModel.h"

#import "KeepAccountsViewController.h"
#import "ViewController.h"

#import "RMSPieView.h"
#import "Utils.h"

@interface TransactionDelegate ()
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSMutableDictionary *allDataClassified;
@property (nonatomic, strong) NSMutableArray *allData;
@property (nonatomic, strong) NSMutableArray *tempData;
@property (nonatomic, assign) BOOL readOnlyMode;
@end

@implementation TransactionDelegate

-(instancetype)initWithTableView:(UITableView *)tableView context:(NSManagedObjectContext *)context
{
    if(self = [super init])
    {
        // init
        self.context = context;
        self.allData = [NSMutableArray array];
        
        [self refreshDataFromDatabase: tableView beginDate:nil endDate:nil refreshFunction:^{
            [self classifyDataByDateFormat: @"yyyy-MM-dd (EEE)"];
        }];
    }
    
    return self;
}

- (void)classifyDataByDateFormat:(NSString *)dateFormat {
    [self setReadOnlyMode:NO];
    
    self.allDataClassified = [[NSMutableDictionary alloc] init];

    // Init date time formatter.
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: dateFormat];
    
    // Iterator all data.
    for( Accounting *accounting in self.allData ) {
        NSString *createMonthString = [dateFormatter stringFromDate: accounting.create_time];
        if( createMonthString == nil || [createMonthString isKindOfClass:[NSNull class]] ) {
            createMonthString = @"(null)";
        }
        if( ![[self.allDataClassified allKeys] containsObject: createMonthString] ) {
            [self.allDataClassified setObject:[[NSMutableArray alloc] init] forKey:createMonthString];
        }
        [self.allDataClassified[createMonthString] addObject:
            [AccountingModel transformAccountingToDictionary:accounting]];
    }
    
    //NSLog(@"Dict allDataClassified: %@", self.allDataClassified);
}

- (void)classifyDataByCategoryType: (NSString *)categoryType {
    [self setReadOnlyMode:YES];
    
    self.allDataClassified = [[NSMutableDictionary alloc] init];
    
    if( categoryType == nil ) {
        [self.allDataClassified setObject:[[NSMutableArray alloc] init] forKey:@"Expenses"];
        [self.allDataClassified setObject:[[NSMutableArray alloc] init] forKey:@"Income"];
    }
    else {
        [self.allDataClassified setObject:[[NSMutableArray alloc] init] forKey:categoryType];
    }

    // Iterator all data.
    NSArray *categories = [CategoryModel getCategories:self.context];
    NSMutableDictionary *categoried_accounting = [[NSMutableDictionary alloc] init];
    
    // Default value
    for( Category *category in categories ) {
        NSMutableDictionary *accounting = [[NSMutableDictionary alloc] init];
        [accounting setObject:(category.name == nil ? @"" : category.name) forKey:@"category"];
        [accounting setObject:[NSDecimalNumber zero] forKey: @"amount"];
        if( [category.type isEqualToString:@"Income"] ) {
            [accounting setObject:kPieRandColor forKey: @"color"];
        }
        else {
            [accounting setObject:kPieRandColor forKey: @"color"];
        }
        [categoried_accounting setObject:accounting forKey:category.name];
    }
    // Calculate
    for( Accounting *accounting in self.allData ) {
        if( accounting.category != nil && ![accounting.category isEqualToString:@""] ) {
            NSMutableDictionary *ac = categoried_accounting[accounting.category];
            NSLog(@"ac: %@", ac);
            [ac setObject:[ac[@"amount"] decimalNumberByAdding:accounting.amount] forKey:@"amount"];
            [categoried_accounting setObject:ac forKey:accounting.category];
        }
    }
    // Classify
    for( Category *category in categories ) {
        @try {
            NSMutableDictionary *accounting = categoried_accounting[category.name];
            if( [accounting[@"amount"] compare:[NSDecimalNumber zero]] != NSOrderedSame ) {
                if(categoryType == nil || [categoryType isEqualToString: category.type])
                    [self.allDataClassified[category.type] addObject: accounting];
            }
        }
        @catch(NSException *e) {
            NSLog(@"Error occur while adding classifying category data: %@", e);
        }
    }
    // Sort
    for( NSString *key in [self.allDataClassified allKeys] ) {
        NSArray *unsequencedArray = self.allDataClassified[key];
        NSArray *sequencedArray = [unsequencedArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
            NSComparisonResult result =
                [[Utils decimalNumberAbs: [obj1 objectForKey:@"amount"]]
                 compare:
                 [Utils decimalNumberAbs: [obj2 objectForKey:@"amount"]]];
            return result == NSOrderedAscending;
        }];
        [self.allDataClassified setObject:sequencedArray forKey:key];
    }
}

- (NSMutableDictionary *) getClassifiedData {
    return self.allDataClassified;
}

- (void)refreshDataFromDatabase: (UITableView *)tableView
                      beginDate: (NSDate *)beginDate
                        endDate: (NSDate *)endDate
                refreshFunction: (void(^)(void))refreshFunction {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Accounting" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    
    if(beginDate && endDate) {
        NSPredicate *predicate_date = [NSPredicate predicateWithFormat:@"create_time >= %@ AND create_time <= %@", beginDate, endDate];
        [fetchRequest setPredicate:predicate_date];
    }
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"create_time" ascending:false];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.context executeFetchRequest:fetchRequest error:&error];
    if( fetchedObjects == nil ) {
        NSLog(@"Nothing fetched.");
    }
    else {
        // append data.
        [self.allData removeAllObjects];
        [self.allData addObjectsFromArray:fetchedObjects];
        
        // run refresh function.
        refreshFunction();

        // refresh table view.
        [tableView reloadData];
    }
}

- (NSArray *)sortKeyArray:(NSArray *)unsequencedArray {
    NSArray* sequencedKeyArray =
    [unsequencedArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
        NSComparisonResult result = [obj1 compare:obj2];
        return result == NSOrderedAscending;
    }];
    
    return sequencedKeyArray;
}

- (BOOL)isBlankData {
    return !([[self.allDataClassified allKeys] count] > 0);
}

#pragma mark How many groups.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return ![self isBlankData] ? [[self.allDataClassified allKeys] count]: 1;
}

#pragma mark How many lines in a group.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *keys = [self sortKeyArray:[self.allDataClassified allKeys]];
    NSInteger number = 0;
    if( ![self isBlankData] ) {
        number = [self.allDataClassified[keys[section]] count];
        number = number ? number : 1;
    }
    else {
        number = 1;
    }
    
    return number;
}

#pragma mark Header title
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return ![self isBlankData] ? [self sortKeyArray:[self.allDataClassified allKeys]][section]: nil;
}

#pragma mark Style
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* emptyCellIdentity = @"EmptyInfoTableViewCell";
    static NSString* normalCellIdentity = @"TransactionTableViewCell";

    NSArray *keys = [self sortKeyArray:[self.allDataClassified allKeys]];
    
    if( ![self isBlankData] ) {
        if( [self.allDataClassified[keys[indexPath.section]] count] ) {
            NSMutableDictionary *currentData =
            [[self.allDataClassified objectForKey:keys[indexPath.section]] objectAtIndex:indexPath.row];
            
            TransactionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:normalCellIdentity forIndexPath:indexPath];
            
            NSString *numberCurrencyStyleStr = [NSNumberFormatter localizedStringFromNumber:currentData[@"amount"] numberStyle:NSNumberFormatterCurrencyStyle];
            
            cell.categoryNameLabel.text = currentData[@"category"];
            cell.amountLabel.text = [[NSString alloc] initWithFormat:@"%@", numberCurrencyStyleStr];
            
            if( [currentData[@"amount"] compare:[NSDecimalNumber zero]] == NSOrderedDescending ) {
                [cell.amountLabel setTextColor:[UIColor colorWithRed:.2 green:.5 blue:.35 alpha:1]];
            } else {
                [cell.amountLabel setTextColor:[UIColor redColor]];
            }
            
            if( [[currentData allKeys] containsObject: @"color"] ) {
                [cell.categoryColorView setBackgroundColor: currentData[@"color"]];
            }
            else {
                [cell.categoryColorView setBackgroundColor: [UIColor clearColor]];
            }
            
            Category *category = [CategoryModel getCategoryByName:currentData[@"category"] context:self.context];
            if( category ) {
                [cell.categoryIconLabel setText:category.icon];
            }
            
            tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
            
            return cell;
        }
        else {
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            
            EmptyInfoTableViewCell *emptyCell = [tableView dequeueReusableCellWithIdentifier:emptyCellIdentity forIndexPath:indexPath];
            emptyCell.userInteractionEnabled = NO;
            emptyCell.emptyIcon.text = @"";
            return emptyCell;
        }
    }
    else {
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        EmptyInfoTableViewCell *emptyCell = [tableView dequeueReusableCellWithIdentifier:emptyCellIdentity forIndexPath:indexPath];
        emptyCell.userInteractionEnabled = NO;
        emptyCell.emptyIcon.text  = @"\U0000F01C";
        return emptyCell;
    }
}

#pragma Delete row from table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.readOnlyMode || [self isBlankData]) return NO;
    else return YES;
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Delete";
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSArray *keys = [self sortKeyArray:[self.allDataClassified allKeys]];
        NSDictionary *currentData =
            [[self.allDataClassified objectForKey:keys[indexPath.section]] objectAtIndex:indexPath.row];
        NSLog(@"currentData: %@", currentData);
        Accounting *deleteAccounting = (Accounting *)[self.context objectWithID:currentData[@"objectID"]];

        // delete from database
        [self.context deleteObject: deleteAccounting];
        NSError *error = nil;
        if (![self.context save:&error]) {
            NSLog(@"error: %@",error);
        }
        else {
            // delete local
            [[self.allDataClassified objectForKey:keys[indexPath.section]] removeObjectAtIndex:indexPath.row];

            // delete empty category
            if( ![[self.allDataClassified objectForKey:keys[indexPath.section]] count] ) {
                // delete section from table view
                [self.allDataClassified removeObjectForKey:keys[indexPath.section]];
            }
            else {
                // delete item from table view
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
            
            // refresh
            [tableView reloadData];
            
            @try {
                [(ViewController *)[self findViewController:tableView] refreshView];
            }
            @catch(NSException *e) {
                NSLog(@"Error in excuting view controller method: refreshView");
            }
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if( [self isBlankData] ) {
        /*
         * It's hard to get dynamic height of tableView in this delegate
         */
        /*
        CGSize size = [tableView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        return size.height + 1.0f;
         */
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSInteger mainTableViewNormalHeight = [userDefaults integerForKey:@"mainTableViewNormalHeight"];
        if (mainTableViewNormalHeight < 100) {
            mainTableViewNormalHeight = tableView.bounds.size.height;
            [userDefaults setInteger:mainTableViewNormalHeight forKey:@"mainTableViewNormalHeight"];
        }
        return mainTableViewNormalHeight;
    }
    else {
        NSArray *keys = [self sortKeyArray:[self.allDataClassified allKeys]];
        if( [self.allDataClassified[keys[indexPath.section]] count] ) {
            NSString *identifier = @"TransactionTableViewCell";
            UITableViewCell *cell = (UITableViewCell *)([tableView dequeueReusableCellWithIdentifier:identifier]);
            return cell.frame.size.height;
        }
        else {
            return 66;
        }
    }
}

#pragma mark Select row
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( !self.readOnlyMode && ![self isBlankData] ) {
        NSArray *keys = [self sortKeyArray:[self.allDataClassified allKeys]];
        NSDictionary *currentData =
            [[self.allDataClassified objectForKey:keys[indexPath.section]] objectAtIndex:indexPath.row];
        
        // jump to edit
        KeepAccountsViewController *controller =
            [tableView.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"keep-accounts"];
        controller.accountingId = currentData[@"objectID"];
        controller.accountingDate = currentData[@"create_time"];
        controller.accountingTags = currentData[@"tags"];
        if( !(controller.accountingTags == nil || [controller.accountingTags isEqualToString:@""]) )
            controller.selectedTags = [controller.accountingTags componentsSeparatedByString: @","];
        controller.accountingComment = currentData[@"comment"];
        controller.accountingCategory = currentData[@"category"];
        controller.accountingAmount = currentData[@"amount"];
        controller.categoryIcon = [CategoryModel getCategoryIconByName:controller.accountingCategory context:self.context];
        [tableView.window.rootViewController showViewController:controller sender:nil];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UIViewController *)findViewController:(UIView *)sourceView
{
    id target=sourceView;
    while (target) {
        target = ((UIResponder *)target).nextResponder;
        if ([target isKindOfClass:[UIViewController class]]) {
            break;
        }
    }
    return target;
}

@end
