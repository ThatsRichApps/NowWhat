//
//  TemplateListViewController.h
//  NowWhat
//
//  Created by Rich Humphrey on 10/20/13.
//  Copyright (c) 2013 Rich Humphrey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Template.h"
#import "TemplateCell.h"
#import "ShowTemplateViewController.h"
#import "SaveTemplateViewController.h"
#import "MainInfoViewController.h"

@interface TemplateListViewController : UITableViewController <NSFetchedResultsControllerDelegate> {
    
//    IBOutlet UILabel *templateNameLabel;

    // this name is from apple... lets the frc know that the user is changing rows, so don't update yet
    BOOL changeIsUserDriven;
    
}

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsControllerTemplates;

@property (nonatomic, retain) NSDate *viewNSDate;
@property (nonatomic, retain) Schedule *viewSchedule;

@end
