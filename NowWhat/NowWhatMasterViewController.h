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
#import "UnmanagedEvent.h"

@class NowWhatDetailViewController;
@class Event;
//@class UnmanagedEvent;

@interface NowWhatMasterViewController : UITableViewController <NSFetchedResultsControllerDelegate, ChangeDateViewControllerDelgate, EditEventViewControllerDelgate>


@property (strong, nonatomic) NowWhatDetailViewController *detailViewController;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) NSString *viewDate;
@property (nonatomic, retain) NSDate *viewNSDate;
@property (nonatomic, retain) NSString *viewSchedule;
@property (nonatomic, assign) BOOL isLocked;
@property (nonatomic, assign) int correctPassword;


@end
