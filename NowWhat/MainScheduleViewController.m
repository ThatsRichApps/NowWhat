//
//  MainScheduleViewController.m
//  NowWhat
//
//  Created by Rich Humphrey on 11/1/13.
//  Copyright (c) 2013 Rich Humphrey. All rights reserved.
//

#import "MainScheduleViewController.h"
#define kViewNSDate @"viewNSDate"
#define kViewDate @"viewDate"
#define kViewSchedule @"viewSchedule"
#define kIsLocked @"isLocked"

@interface MainScheduleViewController ()

@end

@implementation MainScheduleViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    /*
    // try a uinotification here
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:10];
    localNotification.alertBody = @"Alert from viewdidload mainschedule";
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    */
    
    // set initial viewDate and viewNSDate here if not set, need to have them passed back from master
    // if the master changes them
    
    
    // check to see if there were default settings persisted in the userdefaults
    NSUserDefaults *previousLoad = [NSUserDefaults standardUserDefaults];
    
    // check last the time the app was last loaded
    // if it's been more than 12 hours, reset to today instead of the previous viewNSDate
    
        
    self.viewNSDate = [previousLoad objectForKey:kViewNSDate];
    self.viewDate = [previousLoad objectForKey:kViewDate];
    
    self.viewSchedule = [Schedule returnScheduleForName:[previousLoad objectForKey:kViewSchedule] inContext:self.managedObjectContext];
    
    // if the current viewDate and viewNSDate are nil, set them to today
    if (self.viewNSDate == nil) {
        
        self.viewNSDate = [[NSDate alloc] init];
        self.viewDate = [Event returnDateString:self.viewNSDate];
        
        //NSLog(@" date selected is %@", self.viewDate);
        
        // now set the viewNSDate time to 8:00 am
        self.viewNSDate = [Event resetToBaseTime:self.viewNSDate];
        
        //NSLog(@"base time is %@", self.viewNSDate);
        
        self.viewSchedule = nil;
        
    }
    
    self.detailViewController = (NowWhatDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    self.detailViewController.managedObjectContext = self.managedObjectContext;
    
    // show the bottom toolbar
    [self.navigationController setToolbarHidden:NO];
    
    
    // if the view schedule is already set, go straight to the MainView
    
    if (self.viewSchedule != nil) {
        [self performSegueWithIdentifier:@"ViewPreviousSchedule" sender:self];
    }
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

/*
 - (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
 {
 return [dayEvents count];
 }
 */

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"ViewSchedule" sender:[tableView cellForRowAtIndexPath: indexPath]];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
    //return [dayEvents count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ScheduleCell"];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        NSError *error = nil;
        if (![context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // Do nothing yet, handle it in prepare for segue
    
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    
    ScheduleCell *scheduleCell = (ScheduleCell *)cell;
    Schedule *schedule = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    scheduleCell.scheduleNameLabel.text = schedule.scheduleName;
    
}


#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Schedule" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"scheduleName" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Clear out any previous cache
    [NSFetchedResultsController deleteCacheWithName:@"Schedules"];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Schedules"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    
    
    
    
    
    return _fetchedResultsController;
}

- (void)performFetch
{
    NSError *error;
    if (![self.fetchedResultsController performFetch:&error]) {
        //FATAL_CORE_DATA_ERROR(error);
        NSLog(@"database error");
        return;
    }
}



- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}


// Add Schedule View Controller Delegate Methods
- (void)addScheduleView:(AddScheduleViewController *)controller addSchedule:(NSString *)scheduleName;
{
    
    // add a new event to the managedObjectContext and save to store
    Schedule *schedule = nil;
    schedule = [NSEntityDescription insertNewObjectForEntityForName:@"Schedule" inManagedObjectContext:self.managedObjectContext];
    
    schedule.scheduleName = scheduleName;
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Error: %@", error);
        abort();
    }
    
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    
    
    if ([[segue identifier] isEqualToString:@"InfoSchedules"]) {
        
        UINavigationController *navigationController = segue.destinationViewController;
        MainInfoViewController *controller = (MainInfoViewController *)navigationController;
        controller.callingView = @"InfoSchedules";
        
    }    
    if ([[segue identifier] isEqualToString:@"AddSchedule"]) {
        
        UINavigationController *navigationController = segue.destinationViewController;
        AddScheduleViewController *controller = (AddScheduleViewController *)navigationController.topViewController;
        
        controller.managedObjectContext = self.managedObjectContext;
        controller.delegate = self;
        
    }
    
    if ([[segue identifier] isEqualToString:@"ViewSchedule"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        
        Schedule *selectedSchedule = nil;
        selectedSchedule = [self.fetchedResultsController objectAtIndexPath:indexPath];

        UINavigationController *navigationController = segue.destinationViewController;
        NowWhatMasterViewController *controller = (NowWhatMasterViewController *)navigationController;
        
        controller.managedObjectContext = self.managedObjectContext;
        controller.viewDate = self.viewDate;
        controller.viewNSDate = self.viewNSDate;
        controller.viewSchedule = selectedSchedule;
        controller.detailViewController = self.detailViewController;
        controller.delegate = self;
        
    }
    
    if ([[segue identifier] isEqualToString:@"ViewPreviousSchedule"]) {
        
        UINavigationController *navigationController = segue.destinationViewController;
        NowWhatMasterViewController *controller = (NowWhatMasterViewController *)navigationController;
        
        controller.managedObjectContext = self.managedObjectContext;
        controller.viewDate = self.viewDate;
        controller.viewNSDate = self.viewNSDate;
        controller.viewSchedule = self.viewSchedule;
        controller.detailViewController = self.detailViewController;
        controller.delegate = self;
        
    }

    
    
    
    

}

#pragma mark - CategoryPickerViewControllerDelegate
- (void)changeDatePicker:(ChangeDateViewController *)controller didChangeDate:(NSDate *)newDate {
    
    // update the viewDate variables, reload all the new data, and update the table
    
    self.viewNSDate = newDate;
    self.viewDate = [Event returnDateString:newDate];
    
    //NSLog(@"didChangDate - the new date is %@", self.viewNSDate);
    
}





@end
