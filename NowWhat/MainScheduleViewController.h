//
//  MainScheduleViewController.h
//  NowWhat
//
//  Created by Rich Humphrey on 11/1/13.
//  Copyright (c) 2013 Rich Humphrey. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ScheduleCell.h"
#import "Schedule.h"
#import "NowWhatMasterViewController.h"
#import "AddScheduleViewController.h"
@class NowWhatDetailViewController;



@interface MainScheduleViewController : UITableViewController <NSFetchedResultsControllerDelegate, AddScheduleViewControllerDelgate> {
    
}

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NowWhatDetailViewController *detailViewController;


@end
