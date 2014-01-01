//
//  NowWhatDetailViewController.h
//  NowWhat
//
//  Created by Rich Humphrey on 10/14/13.
//  Copyright (c) 2013 Rich Humphrey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UnmanagedEvent.h"
#import "Event.h"
#import "EventCell.h"
#import "Schedule.h"
#import "NowWhatMasterViewController.h"

@class NowWhatMasterViewController;

@interface NowWhatDetailViewController : UIViewController <UISplitViewControllerDelegate, NSFetchedResultsControllerDelegate, UITableViewDelegate,
        UITableViewDataSource, UITextFieldDelegate> {
    
    Event *lastEvent;
    Event *nextEvent;
    
    IBOutlet UILabel *nextEventLabel;
    IBOutlet UILabel *timeToNextEventLabel;
    IBOutlet UILabel *scheduleLabel;
    IBOutlet UITextField *scheduleField;
    IBOutlet UILabel *pressPlusLabel;
    UITapGestureRecognizer *tap;
            
            

    
}

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (nonatomic, retain) IBOutlet UILabel *countdownLabel;

@property (nonatomic, retain) NSString *viewDate;
@property (nonatomic, retain) NSDate *viewNSDate;
@property (nonatomic, retain) Schedule *viewSchedule;
@property (nonatomic, retain) IBOutlet UITableView *detailTableView;

@property (strong, nonatomic) NowWhatMasterViewController *masterViewController;



// core data properties:
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsControllerDetail;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (void)updateDetailView;

- (void)lockIt;
- (void)unlockIt;

@end
