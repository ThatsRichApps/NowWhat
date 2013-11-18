//
//  SaveTemplateViewController.h
//  NowWhat
//
//  Created by Rich Humphrey on 10/21/13.
//  Copyright (c) 2013 Rich Humphrey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Template.h"
#import "Event.h"
#import "EventCell.h"
#import "TemplateEvent.h"
#import "UnmanagedEvent.h"
#import "EditEventViewController.h"
#import "MainInfoViewController.h"


@interface SaveTemplateViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, EditEventViewControllerDelgate,UITextFieldDelegate, UIAlertViewDelegate> {
    
    IBOutlet UITextField *templateNameField;
    IBOutlet UITableView *saveTableView;
    
    
}

//@property (nonatomic, retain) Template *thisTemplate;
@property (nonatomic, retain) NSMutableArray *templateEvents;
@property (nonatomic, retain) NSString *templateNameForField;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

// baseTime is used to keep track of the time so that it can be reused every time you add or edit
// it is usually preset to 8 am, but I could probably make that a setting
@property (nonatomic, retain) NSDate *baseTime;

- (IBAction)cancel;
- (IBAction)save;

@end
