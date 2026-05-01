//
//  CategoryViewController.m
//  Accounting
//
//  Created by AmeRin on 13/10/2017.
//  Copyright © 2017 RM studio. All rights reserved.
//

#import "CategoryViewController.h"
#import "AppDelegate.h"

#import "Category+CoreDataClass.h"
#import "Category+CoreDataProperties.h"

#import "CategoryModel.h"
#import "Utils.h"

#import <WatchConnectivity/WatchConnectivity.h>


@interface CategoryViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSManagedObjectContext *context;
//@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (nonatomic, strong) NSMutableArray *allData;
@end

@implementation CategoryViewController

- (IBAction)editCategories:(id)sender {
    BOOL flag = !self.tableView.editing;
    [self.tableView setEditing:flag animated:YES];
}

- (IBAction)appendCategory:(id)sender {
    [self generateEditDialog:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Load context.
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.context = delegate.persistentContainer.viewContext;
    
    // init
    self.allData = [NSMutableArray array];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self getDataFromDatabase];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)generateEditDialog:(Category*) category {
    
    NSString *alertTitle = [[NSString alloc] init];
    if(category == nil) {
        alertTitle = @"New category";
    }
    else {
        alertTitle = @"Edit category";
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle message:@"Please input the content" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *incomeAction =
        [UIAlertAction actionWithTitle:@"Set As 'Income'" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self saveCategory:category name:alertController.textFields.firstObject.text icon:alertController.textFields.lastObject.text
                         alias:@"" type: @"Income"];
    }];
    [incomeAction setValue:[UIColor colorWithRed:0/255.0f green:201/255.0f blue:87/255.0f alpha:1] forKey:@"_titleTextColor"];
    
    UIAlertAction *expensesAction =
        [UIAlertAction actionWithTitle:@"Set As 'Expenses'" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self saveCategory:category name:alertController.textFields.firstObject.text icon:alertController.textFields.lastObject.text
                         alias:@"" type: @"Expenses"];
    }];
    [expensesAction setValue:[UIColor redColor] forKey:@"_titleTextColor"];
    
    [alertController addAction:incomeAction];
    [alertController addAction:expensesAction];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil]];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Name";
        if(category != nil) { textField.text = category.name; }
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Emoji Icon";
        if(category != nil) { textField.text = category.icon; }
        
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

- (void)saveCategory:(Category *) category name:(NSString *)name icon:(NSString *)icon alias:(NSString *)alias type:(NSString *)type {
    if(category == nil) {
        // add new.
        Category *new_category = [NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:self.context];
        new_category.name = name;
        new_category.alias = alias;
        new_category.icon = icon;
        new_category.type = type;
        new_category.sequence = [self.allData count];
    }
    category.name = name;
    category.alias = alias;
    category.icon = icon;
    category.type = type;
    
    NSError *error = nil;
    if( [self.context save:&error] ) {
        NSLog(@"Save success.");
        
        // Update UI
        [self getDataFromDatabase];
        
        // WC updateApplicationContext
        [AppDelegate updateApplicationContextForCategory:self.context];
    } else {
        NSLog(@"%@", [NSString stringWithFormat:@"found core data error: %@", [error localizedDescription]]);
    }
}

- (void)getDataFromDatabase {
    NSArray *fetchedObjects = [CategoryModel getCategories:self.context];
    if( fetchedObjects == nil ) {
        NSLog(@"Nothing fetched.");
    }
    else {
        // append data.
        [self.allData removeAllObjects];
        [self.allData addObjectsFromArray:fetchedObjects];

        // refresh table view.
        [self.tableView reloadData];
        
        NSLog(@"Category Data: %@", self.allData);
    }
}

/******************************** Datasource ********************************/

#pragma mark How many groups.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

#pragma mark How many lines in a group.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.allData count];
}

#pragma mark Style
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil ];

    Category *currentData = self.allData[indexPath.row];
    if( currentData.icon == nil ) {
        currentData.icon = @"🏷";
    }
    cell.textLabel.text = [[NSString alloc] initWithFormat:@"%@ %@", currentData.icon, currentData.name];
    
    // draw a dot, colored based category type.
    CGFloat R = 10;
    UIView *categoryTypeView = [[UIView alloc] initWithFrame:
         CGRectMake(self.view.frame.size.width - 30, (cell.frame.size.height-R)/2, R, R)];
    categoryTypeView.layer.cornerRadius = R / 2;
    
    if( [currentData.type characterAtIndex:0] == 'I' ) {
        [categoryTypeView setBackgroundColor:[UIColor colorWithRed:0/255.0f green:201/255.0f blue:87/255.0f alpha:1]];
    }
    else {
        [categoryTypeView setBackgroundColor:UIColor.redColor];
    }
    [cell.contentView addSubview:categoryTypeView];
    
    return cell;
}

#pragma mark Delete row from table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
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
        Category *currentData = self.allData[indexPath.row];

        // delete from database
        [self.context deleteObject: currentData];
        NSError *error = nil;
        if (![self.context save:&error]) {
            NSLog(@"error:%@",error);
        }
        
        // delete local
        [self.allData removeObjectAtIndex:indexPath.row];

        // delete from table view
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    Category *category= self.allData[sourceIndexPath.row];
    [self.allData removeObject:category];
    [self.allData insertObject:category atIndex:destinationIndexPath.row];
    
    BOOL inc = sourceIndexPath.row > destinationIndexPath.row;
    NSInteger start = inc ? destinationIndexPath.row: sourceIndexPath.row;
    NSInteger end = inc ? sourceIndexPath.row: destinationIndexPath.row;
    for( NSInteger i = start; i <= end; i++ ) {
        Category *c = self.allData[i];
        c.sequence = i;
    }
    
    NSError *error = nil;
    if (![self.context save:&error]) {
        NSLog(@"error:%@",error);
    }
    else {
        // WC updateApplicationContext
        [AppDelegate updateApplicationContextForCategory:self.context];
    }
}

/******************************** Delegate ********************************/

#pragma mark Select row
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self generateEditDialog: self.allData[indexPath.row]];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Navigation
 
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    id theSegue = segue.destinationViewController;
    if( [theSegue isEqualToString:@"CategoryListSegue"] ) {
        [theSegue setValue:self.allData forKey:@"pickerArray"];
    }
}

@end
