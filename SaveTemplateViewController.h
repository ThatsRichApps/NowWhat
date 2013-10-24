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

@interface SaveTemplateViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    
    IBOutlet UITextField *templateNameField;

}

@property (nonatomic, retain) Template *thisTemplate;
@property (nonatomic, retain) NSMutableArray *templateEvents;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

- (IBAction)cancel;
- (IBAction)save;

@end
