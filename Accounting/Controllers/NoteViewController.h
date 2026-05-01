//
//  NoteViewController.h
//  Accounting
//
//  Created by AmeRin on 20/11/2017.
//  Copyright © 2017 RM studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NoteViewController : UIViewController <UITextViewDelegate>
@property (nonatomic, strong) NSString *accountingComment;
@end
