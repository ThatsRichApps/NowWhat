//
//  NowWhatMasterViewController.h
//  NowWhat
//
//  Created by Rich Humphrey on 10/14/13.
//  Copyright (c) 2013 Rich Humphrey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "EditEventViewController.h"
#import "ChangeDateViewController.h"
#import "TemplateListViewController.h"
#import "SaveTemplateViewController.h"
#import "PasswordViewController.h"
#import "UnmanagedEvent.h"
#import "NowWhatDetailViewController.h"
#import "EventCell.h"

@class NowWhatDetailViewController;
@class Event;
//@class UnmanagedEvent;

@interface NowWhatMasterViewController : UITableViewController <NSFetchedResultsControllerDelegate, ChangeDateViewControllerDelgate, EditEventViewControllerDelgate, PasswordViewControllerDelegate> {
    
    NSMutableArray *saveButtonItems;
    
}


@property (strong, nonatomic) NowWhatDetailViewController *detailViewController;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) NSString *viewDate;
@property (nonatomic, retain) NSDate *viewNSDate;
@property (nonatomic, retain) NSString *viewSchedule;
@property (nonatomic, assign) BOOL isLocked;
@property (nonatomic, assign) int correctPassword;


- (IBAction)printSchedule:(id) sender;


@end
