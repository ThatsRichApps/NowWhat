//
//  NowWhatMasterViewController.h
//  NowWhat
//
//  Created by Rich Humphrey on 10/14/13.
//  Copyright (c) 2013 Rich Humphrey. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NowWhatDetailViewController;
@class Event;

#import <CoreData/CoreData.h>
#import "EditEventViewController.h"

@interface NowWhatMasterViewController : UITableViewController <NSFetchedResultsControllerDelegate> {

    
}


@property (strong, nonatomic) NowWhatDetailViewController *detailViewController;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) NSString *viewDate;
@property (nonatomic, retain) NSDate *viewNSDate;
@property (nonatomic, retain) NSString *viewSchedule;
@property (nonatomic, assign) BOOL isLocked;
@property (nonatomic, assign) int correctPassword;
@property (nonatomic, retain) NSDate *baseTime;


@end
