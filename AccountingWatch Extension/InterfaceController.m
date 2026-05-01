//
//  InterfaceController.m
//  AccountingWatch Extension
//
//  Created by AmeRin on 21/10/2017.
//  Copyright © 2017 RM studio. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <WatchConnectivity/WatchConnectivity.h>

#import "InterfaceController.h"
#import "CategoryRow.h"

#import "Category+CoreDataClass.h"
#import "Category+CoreDataProperties.h"


@interface InterfaceController () <WCSessionDelegate>
@property (strong, nonatomic) WCSession *session;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceTable *tableView;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *syncLabel;
@property (nonatomic, strong) NSMutableArray *categories;
@property (nonatomic, strong) NSMutableArray *icons;
@property (nonatomic, strong) NSDecimalNumber *amount;
@end

@implementation InterfaceController

-(instancetype)init {
    self = [super init];
    
    if (self) {
        if ([WCSession isSupported]) {
            self.session = [WCSession defaultSession];
            self.session.delegate = self;
            [self.session activateSession];
        }
    }
    return self;
}

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    // Configure interface objects here.
    self.amount = [[NSDecimalNumber alloc]initWithString:@"0"];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex {
    NSLog(@"selected row :%ld", (long)rowIndex);
    NSDictionary *context = @{@"Category": [self.categories objectAtIndex:rowIndex], @"Icon": [self.icons objectAtIndex:rowIndex]};
    [self pushControllerWithName:@"AmountController" context:context];
}

- (void)configureTableWithCategories:(NSArray *)categories forIcons: icons {
    [self.tableView setNumberOfRows:[categories count] withRowType:@"categoryRow"];
    for (NSInteger i = 0; i < self.tableView.numberOfRows; i++) {
        CategoryRow* row = [self.tableView rowControllerAtIndex:i];
        NSString* category = [categories objectAtIndex:i];
        NSString* icon = [icons objectAtIndex:i];
        if(icon == nil) icon = @"";
        
        [row.categoryLabel setText: [[NSString alloc]initWithFormat:@"%@ %@", icon, category]];
    }
}

#pragma mark - Watch Connectivity Delegate
- (void)session:(nonnull WCSession *)session activationDidCompleteWithState:(WCSessionActivationState)activationState error:(nullable NSError *)error {
    // TO-DO
    NSLog(@"WCSession is activate.");
    
    // f**k!! : while application context is available, func 'didReceiveApplicationContext' will not be loaded.
    [self updateCategoryView:self.session.receivedApplicationContext];
}

- (void)session:(WCSession *)session didReceiveApplicationContext:(NSDictionary<NSString *,id> *) applicationContext {
    NSLog(@"application context is updated.");
    [self updateCategoryView:self.session.receivedApplicationContext];
}

- (void)updateCategoryView:(NSDictionary<NSString *,id> *) applicationContext {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"didReceiveApplicationContext");
        NSLog(@"self.categories: %@", applicationContext[@"Categories"]);
        
        self.categories = [applicationContext objectForKey: @"Categories"];
        self.icons = [applicationContext objectForKey: @"Icons"];
        if(self.categories) {
            [self.syncLabel setHidden:YES];
            [self configureTableWithCategories: self.categories forIcons: self.icons];
        }
        else {
            [self.syncLabel setHidden:NO];
        }
    });
}

@end
