//
//  ShowTemplateViewController.h
//  NowWhat
//
//  Created by Rich Humphrey on 10/23/13.
//  Copyright (c) 2013 Rich Humphrey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "EventCell.h"
#import "TemplateEvent.h"
#import "Event.h"
#import "Template.h"

@interface ShowTemplateViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsControllerTemplateEvents;

@property (nonatomic, retain) NSString *viewDate;
@property (nonatomic, retain) NSString *viewSchedule;

@property (nonatomic, retain) Template *templateToShow;


- (IBAction)loadTemplateEvents;

@end
