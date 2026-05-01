//
//  TagSettingViewController.m
//  Accounting
//
//  Created by AmeRin on 3/12/2017.
//  Copyright © 2017 RM studio. All rights reserved.
//

#import "TagSettingViewController.h"
#import "Tag+CoreDataClass.h"
#import "Tag+CoreDataProperties.h"

#import "TagModel.h"

#import "AppDelegate.h"
#import "TagDelegate.h"

@interface TagSettingViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) TagDelegate *tagDelegate;
@end

@implementation TagSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    // Load context.
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.context = delegate.persistentContainer.viewContext;
    
    // Load view
    [[NSBundle mainBundle] loadNibNamed:@"TagSettingViewController" owner:self options:nil];
    
    // init
    self.tagDelegate = [[TagDelegate alloc] initWithTableView:self.tableView context:self.context];
    self.tableView.dataSource = self.tagDelegate;
    self.tableView.delegate = self.tagDelegate;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"EmptyInfoTableViewCell" bundle: nil] forCellReuseIdentifier:@"EmptyInfoTableViewCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)appendTagButton:(id)sender {
    [self.tagDelegate generateEditDialog: nil];
}

@end
