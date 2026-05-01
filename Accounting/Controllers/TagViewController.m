//
//  TagViewController.m
//  Accounting
//
//  Created by AmeRin on 3/12/2017.
//  Copyright © 2017 RM studio. All rights reserved.
//

#import "TagViewController.h"
#import "TagDelegate.h"

#import "KeepAccountsViewController.h"

#import "AppDelegate.h"

@interface TagViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) TagDelegate *tagDelegate;
@end

@implementation TagViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Load context.
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.context = delegate.persistentContainer.viewContext;
    
    // Load view
    [[NSBundle mainBundle] loadNibNamed:@"TagViewController" owner:self options:nil];

    // init
    self.tagDelegate = [[TagDelegate alloc] initWithTableView:self.tableView context:self.context ReadOnlyMode:YES];
    self.tagDelegate.selectedTags = [[NSMutableArray alloc] initWithArray:self.selectedTags];
    self.tableView.dataSource = self.tagDelegate;
    self.tableView.delegate = self.tagDelegate;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"EmptyInfoTableViewCell" bundle: nil] forCellReuseIdentifier:@"EmptyInfoTableViewCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)add:(id)sender {
    [self.tagDelegate generateEditDialog: nil];
}

- (IBAction)done:(id)sender {
    self.selectedTags = self.tagDelegate.selectedTags;
    KeepAccountsViewController *vc =
        [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
    vc.selectedTags = [[NSArray alloc]initWithArray: self.selectedTags];
    [self.navigationController popViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
