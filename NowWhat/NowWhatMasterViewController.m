//
//  NowWhatMasterViewController.m
//  NowWhat
//
//  Created by Rich Humphrey on 10/14/13.
//  Copyright (c) 2013 Rich Humphrey. All rights reserved.
//

#import "NowWhatMasterViewController.h"
#import "NowWhatDetailViewController.h"
#import "EventCell.h"

@interface NowWhatMasterViewController () {
    
//    NSArray *dayEvents;
    
}
//- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

@implementation NowWhatMasterViewController {
    
    Event *lastEditedEvent;
    
}

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // if the current viewDate and viewNSDate are nil, set them to today
    if (self.viewNSDate == nil) {
        
        self.viewNSDate = [[NSDate alloc] init];
        self.viewDate = [Event returnDateString:self.viewNSDate];
        
        //NSLog(@" date selected is %@", self.viewDate);
        
        // now set the viewNSDate time to 8:00 am
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *components = [[NSDateComponents alloc] init];
        
        NSString *dateString = self.viewDate;
        NSString *monthStr = [dateString substringToIndex:2];
        NSString *dayStr   = [dateString substringWithRange:NSMakeRange(2, 2)];
        NSString *yearStr  = [dateString substringFromIndex:4];
        
        [components setDay:[dayStr intValue]];
        [components setMonth:[monthStr intValue]];
        [components setYear:[yearStr intValue]];
        [components setHour:8];
        [components setMinute:0];
        
        self.viewNSDate = [gregorian dateFromComponents:components];
        //NSLog(@"base time is %@", self.viewNSDate);
        
        
    }

    self.viewSchedule = @"Main Schedule";
    
    [self performFetch];

	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    //UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    //self.navigationItem.rightBarButtonItem = addButton;
    self.detailViewController = (NowWhatDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    self.fetchedResultsController = nil;

}

- (void)viewDidUnload {
    self.fetchedResultsController = nil;
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
    [self performSegueWithIdentifier:@"EditEvent" sender:[tableView cellForRowAtIndexPath: indexPath]];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
    //return [dayEvents count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EventCell"];
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
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    Event *event = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [event toggleChecked];
    [self configureCheckmarkForCell:cell withEvent:event];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        self.detailViewController.detailItem = object;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        [[segue destinationViewController] setDetailItem:object];
    }
    
    if ([[segue identifier] isEqualToString:@"AddEvent"]) {
        
        UINavigationController *navigationController = segue.destinationViewController;
        EditEventViewController *controller = (EditEventViewController *)navigationController.topViewController;
        controller.baseTime = self.viewNSDate;
        controller.eventSchedule = self.viewSchedule;
        controller.managedObjectContext = self.managedObjectContext;
        controller.delegate = self;
        
    }
    if ([[segue identifier] isEqualToString:@"EditEvent"]) {

        
        // Send the EditEventViewController the appropriate event that needs editing
        //NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        lastEditedEvent = [self.fetchedResultsController objectAtIndexPath:indexPath];

        UINavigationController *navigationController = segue.destinationViewController;
        EditEventViewController *controller = (EditEventViewController *)navigationController.topViewController;
        controller.baseTime = self.viewNSDate;
        
        UnmanagedEvent *unmanagedEvent = [[UnmanagedEvent alloc] init];
        
        unmanagedEvent.eventText = lastEditedEvent.eventText;
        unmanagedEvent.eventNotes = lastEditedEvent.eventNotes;
        unmanagedEvent.eventTime = lastEditedEvent.eventNSDate;
        
        controller.eventToEdit = unmanagedEvent;
        controller.delegate = self;
        
        //controller.managedObjectContext = self.managedObjectContext;
        //NSLog(@"the event selected is %@", event.eventText);
        
        
    }

    if ([[segue identifier] isEqualToString:@"ChangeDay"]) {
        
        
        UINavigationController *navigationController = segue.destinationViewController;
        ChangeDateViewController *controller = (ChangeDateViewController *)navigationController.topViewController;
        controller.selectedDate = self.viewNSDate;
        // the changedateviewcontroller delegate implements changedatepicker and updates the viewDate
        controller.delegate = self;
        //NSLog(@"the sent date is %@", self.viewNSDate);
        
    }

    if ([[segue identifier] isEqualToString:@"ListTemplates"]) {
        
        TemplateListViewController *controller = (TemplateListViewController *)[segue destinationViewController];
        controller.managedObjectContext = self.managedObjectContext;
        controller.viewDate = self.viewDate;
        controller.viewSchedule = self.viewSchedule;
        
    }

    if ([[segue identifier] isEqualToString:@"SaveTemplate"]) {
        
        SaveTemplateViewController *controller = (SaveTemplateViewController *)[segue destinationViewController];
        // send the data to the save template in the form of an array
        controller.templateEvents = [self loadEvents];
        controller.managedObjectContext = self.managedObjectContext;
        
    }

    
}

-(NSMutableArray*) loadEvents {
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];

    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"eventNSDate" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];

    // setup the predicate to return just the wanted date
    NSPredicate *requestPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"(eventDate like '%@')", [Event returnDateString:self.viewNSDate]]];
    [fetchRequest setPredicate:requestPredicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (fetchedObjects == nil) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    return [NSMutableArray arrayWithArray:fetchedObjects];

}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"eventNSDate" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // setup the predicate to return just the wanted date
    NSPredicate *requestPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"(eventDate like '%@')", [Event returnDateString:self.viewNSDate]]];
    [fetchRequest setPredicate:requestPredicate];
    
    // Clear out any previous cache
    [NSFetchedResultsController deleteCacheWithName:@"Master"];

    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
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

/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}
*/


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    
    EventCell *eventCell = (EventCell *)cell;
    Event *event = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    eventCell.eventTextLabel.text = event.eventText;
    
    eventCell.eventTimeLabel.text = [event formattedTime] ;
    
    eventCell.eventNotesLabel.text = event.eventNotes;

    [self configureCheckmarkForCell:cell withEvent:event];
    
}

- (void)configureCheckmarkForCell:(UITableViewCell *)cell withEvent:(Event *)event
{
    
    // thisadds a checkmark in the label by the cell if eventChecked is true
    
    EventCell *eventCell = (EventCell *)cell;
    if (event.eventChecked) {
        
        eventCell.eventCheckLabel.text = @"√";
        
    } else {
        
        eventCell.eventCheckLabel.text = @"";
        
    }
}


#pragma mark - CategoryPickerViewControllerDelegate
- (void)changeDatePicker:(ChangeDateViewController *)controller didChangeDate:(NSDate *)newDate {
    
    
    // update the viewDate variables, reload all the new data, and update the table
    
    self.viewNSDate = newDate;
    self.ViewDate = [Event returnDateString:newDate];
    
    //NSLog(@"the new date is %@", self.viewNSDate);
    
    self.fetchedResultsController = nil;
    [self.tableView reloadData];
    
}

#pragma mark - EditEventViewControllerDelegate

- (void)editEventView:(EditEventViewController *)controller didChangeTime:(NSDate *)newDate;
{
    // this should only change the time
    self.viewNSDate = newDate;
    //NSLog(@"the new date is %@", self.viewNSDate);
}

- (void)editEventView:(EditEventViewController *)controller addEvent:(UnmanagedEvent *)unmanagedEvent;
{
    
    // add a new event to the managedObjectContext and save to store
    Event *event = nil;
    event = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
    
    event.eventText = unmanagedEvent.eventText;
    event.eventNotes = unmanagedEvent.eventNotes;
    event.eventNSDate = unmanagedEvent.eventTime;
    event.eventDate = [Event returnDateString:unmanagedEvent.eventTime];
    event.eventChecked = NO;
    event.eventSchedule = self.viewSchedule;

    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Error: %@", error);
        abort();
    }
    
}

- (void)editEventView:(EditEventViewController *)controller editEvent:(UnmanagedEvent *)unmanagedEvent;
{

    // edit the info for the selected event
    //NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    //Event *event = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    
    lastEditedEvent.eventText = unmanagedEvent.eventText;
    lastEditedEvent.eventNotes = unmanagedEvent.eventNotes;
    lastEditedEvent.eventNSDate = unmanagedEvent.eventTime;
    lastEditedEvent.eventDate = [Event returnDateString:unmanagedEvent.eventTime];
    
}




@end
