//
//  TagDelegate.h
//  Accounting
//
//  Created by AmeRin on 3/12/2017.
//  Copyright © 2017 RM studio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "Tag+CoreDataClass.h"
#import "Tag+CoreDataProperties.h"

@interface TagDelegate : NSObject <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSMutableArray *selectedTags;

- (instancetype)initWithTableView:(UITableView *)tableView context:(NSManagedObjectContext *)context;
- (instancetype)initWithTableView:(UITableView *)tableView context:(NSManagedObjectContext *)context ReadOnlyMode:(BOOL)readOnlyMode;
- (void)generateEditDialog:(Tag*) tag;
@end
