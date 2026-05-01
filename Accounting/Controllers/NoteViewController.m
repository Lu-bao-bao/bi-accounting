//
//  NoteViewController.m
//  Accounting
//
//  Created by AmeRin on 20/11/2017.
//  Copyright © 2017 RM studio. All rights reserved.
//

#import "NoteViewController.h"
#import "KeepAccountsViewController.h"
#import "CALayer+Addition.h"

@interface NoteViewController ()
@property (weak, nonatomic) IBOutlet UILabel *placeHolder;
@property (weak, nonatomic) IBOutlet UITextView *commentView;
@end

@implementation NoteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSBundle mainBundle] loadNibNamed:@"NoteViewController" owner:self options:nil];
   
    // init
    self.commentView.delegate = self;
    self.commentView.text = self.accountingComment;
    self.placeHolder.hidden = self.commentView.text.length;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)save:(id)sender {
    self.accountingComment = self.commentView.text;
    KeepAccountsViewController *vc =
        [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
    vc.accountingComment = self.accountingComment;
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView
{
    self.placeHolder.hidden = textView.text.length;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
