//
//  ShowTemplateViewController.m
//  NowWhat
//
//  Created by Rich Humphrey on 10/23/13.
//  Copyright (c) 2013 Rich Humphrey. All rights reserved.
//

#import "ShowTemplateViewController.h"

@interface ShowTemplateViewController ()

@end

@implementation ShowTemplateViewController {
    
    TemplateEvent *lastEditedEvent;
    
}

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
    
    // initiallize baseTime to viewDate at 8am at 0/0/0
    if (self.baseTime == nil) {

        self.baseTime = [NSDate date];
        
        self.baseTime = [Event normalizeDay:self.baseTime];
        self.baseTime = [Event resetToBaseTime:self.baseTime];
        
        NSLog(@"show template base time is %@", self.baseTime);
    }


    [self setTitle:self.templateToShow.templateName];

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender
{
    NSManagedObjectContext *context = [self.fetchedResultsControllerTemplateEvents managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsControllerTemplateEvents fetchRequest] entity];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    // If appropriate, configure the new managed object.
    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
    [newManagedObject setValue:[NSDate date] forKey:@"timeStamp"];
    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsControllerTemplateEvents sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsControllerTemplateEvents sections][section];
    return [sectionInfo numberOfObjects];
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
        NSManagedObjectContext *context = [self.fetchedResultsControllerTemplateEvents managedObjectContext];
        [context deleteObject:[self.fetchedResultsControllerTemplateEvents objectAtIndexPath:indexPath]];
        
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
    
    // what do I do here?? nothing if the segue things works
    
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    
    if ([[segue identifier] isEqualToString:@"AddTemplate"]) {
        
        UINavigationController *navigationController = segue.destinationViewController;
        EditEventViewController *controller = (EditEventViewController *)navigationController.topViewController;
        controller.baseTime = self.baseTime;
        controller.delegate = self;
        
    }

    if ([[segue identifier] isEqualToString:@"EditTemplate"]) {
        
        
        // Send the EditTemplateEventViewController the appropriate event that needs editing
        //NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        lastEditedEvent = [self.fetchedResultsControllerTemplateEvents objectAtIndexPath:indexPath];
        
        UINavigationController *navigationController = segue.destinationViewController;
        EditEventViewController *controller = (EditEventViewController *)navigationController.topViewController;
        
        controller.baseTime = self.baseTime;
        
        UnmanagedEvent *unmanagedEvent = [[UnmanagedEvent alloc] init];
        
        unmanagedEvent.eventText = lastEditedEvent.eventText;
        unmanagedEvent.eventNotes = lastEditedEvent.eventNotes;
        unmanagedEvent.eventTime = lastEditedEvent.eventTime;
        
        controller.eventToEdit = unmanagedEvent;
        controller.delegate = self;
        
        //NSLog(@"the event selected is %@", event.eventText);
        
        
    }
   
    
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsControllerTemplateEvents
{
    if (_fetchedResultsControllerTemplateEvents != nil) {
        return _fetchedResultsControllerTemplateEvents;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TemplateEvent" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"eventTime" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // setup the predicate to return just the wanted date
    NSPredicate *requestPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"(template.templateName like '%@')", self.templateToShow.templateName]];
    [fetchRequest setPredicate:requestPredicate];
    
    // Clear out any previous cache
    [NSFetchedResultsController deleteCacheWithName:@"TemplateEvents"];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *afetchedResultsControllerTemplateEvents = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"TemplateEvents"];
    afetchedResultsControllerTemplateEvents.delegate = self;
    self.fetchedResultsControllerTemplateEvents = afetchedResultsControllerTemplateEvents;
    
	NSError *error = nil;
	if (![self.fetchedResultsControllerTemplateEvents performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsControllerTemplateEvents;
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
    
    // this casts the cell to a EventCell
    EventCell *eventCell = (EventCell *)cell;
    
    // this gets the data from the fetched results
    TemplateEvent *event = [self.fetchedResultsControllerTemplateEvents objectAtIndexPath:indexPath];
    
    // this sets the cell labels
    eventCell.eventTextLabel.text = event.eventText;
    
    eventCell.eventTimeLabel.text = [Event formatEventTime:event.eventTime] ;
    
    eventCell.eventNotesLabel.text = event.eventNotes;
    
    
}


- (IBAction)loadTemplateEvents

{

    // Add these events to the event database
    // do error checking and save to managedObjectContext
    // loop through all the events in the fetchedResultsControllerTemplateEvents and save each one to the current day and schedule
    
    // Now go through all the events in the list and add them to the TemplateEvents entity
    
    for (TemplateEvent *templateEvent in [self.fetchedResultsControllerTemplateEvents fetchedObjects]) {
    
        Event *event = nil;
        event = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
   
        event.eventText = templateEvent.eventText;
        event.eventNotes = templateEvent.eventNotes;
        
        event.eventChecked = NO;
        event.schedule = self.viewSchedule;

        
        // take the time from event.eventTime, and merge with the date that is loaded
        event.eventNSDate = [Event mergeDate:[Event returnDateString:self.viewNSDate] withTime:templateEvent.eventTime];
        event.eventDate = [Event returnDateString:event.eventNSDate];
        
    }
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Error: %@", error);
        abort();
    }
    
    [[self navigationController] popViewControllerAnimated:YES];
    
}


#pragma mark - EditEventViewControllerDelegate

- (void)editEventView:(EditEventViewController *)controller didChangeTime:(NSDate *)newDate;
{
    // this should only change the time
    self.baseTime = newDate;
    //NSLog(@"the new date is %@", self.viewNSDate);
}

- (void)editEventView:(EditEventViewController *)controller addEvent:(UnmanagedEvent *)unmanagedEvent;
{
    
    // add a new event to the managedObjectContext and save to store
    TemplateEvent *templateEvent = nil;
    templateEvent = [NSEntityDescription insertNewObjectForEntityForName:@"TemplateEvent" inManagedObjectContext:self.managedObjectContext];
    
    templateEvent.eventText = unmanagedEvent.eventText;
    templateEvent.eventNotes = unmanagedEvent.eventNotes;
    templateEvent.template = self.templateToShow;
    
    // strip the date off of unmanagedEvent.eventTime
    templateEvent.eventTime = unmanagedEvent.eventTime;
    
    
    
    
    NSLog (@"adding templateEvent at %@", templateEvent.eventTime);
    NSLog (@"Text is: %@", templateEvent.eventText);

    
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
    
    // strip the date off of unmanagedEvent.eventTime
    lastEditedEvent.eventTime = unmanagedEvent.eventTime;
    
}






@end
