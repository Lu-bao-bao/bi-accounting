//
//  TagDelegate.m
//  Accounting
//
//  Created by AmeRin on 3/12/2017.
//  Copyright © 2017 RM studio. All rights reserved.
//

#import "TagDelegate.h"
#import "TagModel.h"

#import "EmptyInfoTableViewCell.h"
#import "TagViewController.h"


@interface TagDelegate ()
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) id controllerContext;
@property (nonatomic, strong) NSMutableArray *allData;
@property (nonatomic, assign) BOOL readOnlyMode;
@property (nonatomic, strong) UIAlertAction *saveAction;

@end

@implementation TagDelegate

- (instancetype)initWithTableView:(UITableView *)tableView context:(NSManagedObjectContext *)context
{
    if(self = [super init])
    {
        // init
        self.context = context;
        self.tableView = tableView;
        self.controllerContext = [self viewController];
        self.allData = [NSMutableArray array];
        self.selectedTags = [[NSMutableArray alloc]init];
        
        // load data
        [self getDataFromDatabase];
    }
    
    return self;
}

- (instancetype)initWithTableView:(UITableView *)tableView context:(NSManagedObjectContext *)context ReadOnlyMode:(BOOL)readOnlyMode
{
    self.readOnlyMode = readOnlyMode;
    return [self initWithTableView:(UITableView *)tableView context:(NSManagedObjectContext *)context];
}

- (UIViewController *)viewController {
    /// Finds the view's view controller.
    
    // Traverse responder chain. Return first found view controller, which will be the view's view controller.
    UIResponder *responder = self.tableView;
    while ((responder = [responder nextResponder]))
        if ([responder isKindOfClass: [UIViewController class]])
            return (UIViewController *)responder;
    
    // If the view controller isn't found, return nil.
    return nil;
}

- (void)getDataFromDatabase {
    NSArray *fetchedObjects = [TagModel getTags:self.context];
    if( fetchedObjects == nil ) {
        NSLog(@"Nothing fetched.");
    }
    else {
        // append data.
        [self.allData removeAllObjects];
        [self.allData addObjectsFromArray:fetchedObjects];
        
        // refresh table view.
        [self.tableView reloadData];
        
        NSLog(@"Tag Data: %@", self.allData);
    }
}

- (void)generateEditDialog:(Tag*) tag {
    
    NSString *alertTitle = [[NSString alloc] init];
    NSString *alertContent = nil;
    
    if(tag == nil) {
        alertTitle = @"New Tag";
    }
    else {
        alertTitle = @"Edit Tag";
        alertContent = [[NSString alloc] initWithFormat: @"Change tag \"%@\" name to", tag.name];
    }
    
    UIAlertController *alertController =
    [UIAlertController alertControllerWithTitle:alertTitle message:alertContent preferredStyle:UIAlertControllerStyleAlert];
    
    self.saveAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *tagTitle = alertController.textFields.firstObject.text;
        if( tagTitle == nil || [tagTitle isEqualToString:@""] ) {
            // TODO: Show alert message here.
        }
        else {
            if(tag == nil) {
                [TagModel appendTag:self.context name:alertController.textFields.firstObject.text color:0 sequence:0];
            }
            else {
                [TagModel updateTag:tag name:alertController.textFields.firstObject.text color:0 sequence:0 context:self.context];
            }
    
            // Update UI
            [self getDataFromDatabase];
        }
    }];
    self.saveAction.enabled = NO;
    
    [alertController addAction:self.saveAction];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil]];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Name";
        if(tag != nil) { textField.text = tag.name; }
        [textField addTarget:self action:@selector(textFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
    }];
    
    [self.controllerContext presentViewController:alertController animated:true completion:nil];
}

- (void)textFieldEditingChanged:(UITextField *)textField
{
    self.saveAction.enabled = (Boolean)[textField.text length];
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

/******************************** Datasource ********************************/

#pragma mark How many groups.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

#pragma mark How many lines in a group.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.allData count] > 0 ? [self.allData count]: 1;
}

#pragma mark Style
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if( [self.allData count] > 0 ) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
        Tag *currentData = self.allData[indexPath.row];
        NSLog(@"currentData: %@", currentData);
        cell.textLabel.text = [[NSString alloc] initWithFormat:@"%@ %@", @"🏷", currentData.name];
    
        if( [self.selectedTags containsObject: currentData.name] ) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }

        // draw a dot, colored based tag color.
        /*
         CGFloat R = 10;
         UIView *tagColorView = [[UIView alloc] initWithFrame:
         CGRectMake(self.view.frame.size.width - 30, (cell.frame.size.height-R)/2, R, R)];
         categoryTypeView.layer.cornerRadius = R / 2;
    
         if( currentData.color ) {
         [categoryTypeView setBackgroundColor:[UIColor colorWithRed:0/255.0f green:201/255.0f blue:87/255.0f alpha:1]];
         }
    
         [cell.contentView addSubview:tagColorView];
         */
    
        return cell;
    }
    else {
        static NSString* cellIdentity = @"EmptyInfoTableViewCell";
        EmptyInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentity forIndexPath:indexPath];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        cell.emptyLabel.text = @"You haven't created any tag yet.";
        cell.emptyIcon.text = @"\U0000F02C";
        cell.userInteractionEnabled = NO;
        [cell.emptyLabel.heightAnchor constraintEqualToConstant:50].active = YES;
        
        return cell;
    }
}

#pragma mark Delete row from table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return !self.readOnlyMode && [self.allData count];
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
        Tag *currentData = self.allData[indexPath.row];
        
        // delete from database
        [self.context deleteObject: currentData];
        NSError *error = nil;
        if (![self.context save:&error]) {
            NSLog(@"error:%@",error);
        }
        else {
            // delete local
            [self.allData removeObjectAtIndex:indexPath.row];
            
            if( [self.allData count] ) {
                // delete from table view
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
            else {
                // refresh
                [tableView reloadData];
            }
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if( ![self.allData count] ) {
        /*
         * It's hard to get dynamic height of tableView in this delegate
         */
        /*
         CGSize size = [tableView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
         return size.height + 1.0f;
         */
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSInteger tagViewNormalHeight = [userDefaults integerForKey:@"tagViewNormalHeight"];
        if (tagViewNormalHeight < 100) {
            tagViewNormalHeight = tableView.bounds.size.height;
            [userDefaults setInteger:tagViewNormalHeight forKey:@"tagViewNormalHeight"];
        }
        return tagViewNormalHeight;
    }
    else {
        return 44;
    }
}

/******************************** Delegate ********************************/

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.readOnlyMode && [self.allData count]) {
        Tag *tag = self.allData[indexPath.row];
        if( [tableView cellForRowAtIndexPath:indexPath].accessoryType == UITableViewCellAccessoryNone ) {
            [self.selectedTags addObject: tag.name];
            [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else {
            [self.selectedTags removeObject: tag.name];
            [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
        }
        
        NSLog(@"selectedTags: %@", self.selectedTags);
    }
    return indexPath;
}

#pragma mark Select row
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(!self.readOnlyMode && [self.allData count]) {
        [self generateEditDialog: self.allData[indexPath.row]];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
