//
//  NumberPadController.m
//  AccountingWatch Extension
//
//  Created by AmeRin on 25/10/2017.
//  Copyright © 2017 RM studio. All rights reserved.
//

#import "NumberPadController.h"
#import "NumberPad.h"
#import <WatchConnectivity/WatchConnectivity.h>

@interface NumberPadController ()
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *numberBoard;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceButton *backspaceKey;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceButton *doneKey;
@property (nonatomic, strong) NumberPad *numberPad;

@property (nonatomic, strong) NSDecimalNumber *amount;
@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) NSString *icon;
@end

@implementation NumberPadController

- (IBAction)oneTapped   { [self appendDigit:'1']; }
- (IBAction)twoTapped   { [self appendDigit:'2']; }
- (IBAction)threeTapped { [self appendDigit:'3']; }
- (IBAction)fourTapped  { [self appendDigit:'4']; }
- (IBAction)fiveTapped  { [self appendDigit:'5']; }
- (IBAction)sixTapped   { [self appendDigit:'6']; }
- (IBAction)sevenTapped { [self appendDigit:'7']; }
- (IBAction)eightTapped { [self appendDigit:'8']; }
- (IBAction)nineTapped  { [self appendDigit:'9']; }
- (IBAction)zeroTapped  { [self appendDigit:'0']; }

- (void)appendDigit: (char)digit {
    [self.numberPad appendDigit:digit];
    [self.numberBoard setText:[self.numberPad getNumberPad]];
    [self.backspaceKey setHidden:[[self.numberPad getNumberPad] isEqualToString:@"0"]];
}

- (IBAction)backspaceTapped {
    [self.numberPad attachBackspace];
    [self.numberBoard setText:[self.numberPad getNumberPad]];
    [self.backspaceKey setHidden:[[self.numberPad getNumberPad] isEqualToString:@"0"]];
}

- (IBAction)dotTapped {
    [self.numberPad appendDot];
    [self.numberBoard setText:[self.numberPad getNumberPad]];
    [self.backspaceKey setHidden:[[self.numberPad getNumberPad] isEqualToString:@"0"]];
}

- (IBAction)doneTapped {
    self.amount = [self.numberPad getDecimalNumber];
    if( [self.amount isEqual:[NSDecimalNumber zero]] ) {
        // do nothing.
        NSLog(@"self.amount is equal to 0, do nothing.");
    }
    else {
        // loading style
        [self.doneKey setEnabled:NO];
        [self.doneKey setTitle:@"Wait"];
        [self.doneKey setBackgroundColor: UIColor.grayColor];

        // create and send message via WC session.
        WCSession *session = [WCSession defaultSession];
        [session sendMessage:@{@"Action": @"create_item", @"Category": self.category, @"Amount": self.amount}
                replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage) {
                    NSLog(@"Watch reveice reply message: %@", replyMessage);
                    if( [replyMessage[@"Action"] isEqualToString: @"create_item"] ) {
                        if( [replyMessage[@"Result"] isEqualToString: @"success"] ) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                // change style.
                                [self.doneKey setBackgroundColor:UIColor.greenColor];
                                [self.backspaceKey setHidden:YES];
                                
                                // alert action.
                                WKAlertAction *successAction =
                                    [WKAlertAction actionWithTitle:@"OK" style:WKAlertActionStyleDefault
                                                   handler:^{
                                                       [self popController]; /* return to last sense. */
                                                   }];
                                [self presentAlertControllerWithTitle:@"Accounting"
                                                              message:@"Save content success."
                                                       preferredStyle:WKAlertControllerStyleAlert
                                                              actions:@[successAction]];
                            });
                        }
                        else {
                            [self popController]; /* return to last sense. */ 
                        }
                    }
                }
                errorHandler:^(NSError * _Nonnull error) {}
        ];
        
    }
}

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    // Get category from context
    self.category = [context objectForKey:@"Category"];
    self.icon = [context objectForKey:@"Icon"];
    NSLog(@"self.category = %@", self.category);
    
    // Configure interface objects here.
    self.numberPad = [[NumberPad alloc]init];
    
    // Set title
    [self setTitle: [[NSString alloc]initWithFormat:@"%@ %@", self.icon, self.category]];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end



