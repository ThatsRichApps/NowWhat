//
//  NowWhatDetailViewController.m
//  NowWhat
//
//  Created by Rich Humphrey on 10/14/13.
//  Copyright (c) 2013 Rich Humphrey. All rights reserved.
//

#import "NowWhatDetailViewController.h"

@interface NowWhatDetailViewController () {

}

@property (strong, nonatomic) UIPopoverController *masterPopoverController;

- (void)configureView;

@end

@implementation NowWhatDetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        self.detailDescriptionLabel.text = [[self.detailItem valueForKey:@"eventText"] description];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Start the time and now what check, then set to recheck every 30 secs
    [self updateTime];
    
    // create a timer that updates the clock
    // repeat every # seconds - low for testing, up to 30 or so for release
    [NSTimer scheduledTimerWithTimeInterval: 5.0
                                     target: self
                                   selector: @selector(updateTime)
                                   userInfo: nil
                                    repeats: YES];
    
    if (self.viewSchedule == nil) {
        scheduleLabel.text = @"Select Schedule to View and Add Events";
        scheduleField.text = @"";
        // and don't let it be editable
        scheduleField.enabled = NO;
    } else {
        scheduleLabel.text = @"Schedule:";
        scheduleField.text = [NSString stringWithFormat:@"%@", self.viewSchedule.scheduleName];
        scheduleField.enabled = YES;
    }
    
    nextEventLabel.text = @"";
    timeToNextEventLabel.text = @"";
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    
    
    barButtonItem.title = NSLocalizedString(@"Events", @"Events");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
    
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

// this is deprecated in ios 6, but still needed in 5
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}


-(void) updateTime {
    
    Event *currentAlert = nextEvent;
    
    // NSLog(@"Update the time and check Now What?");
    
    NSDateFormatter *dayFormatter =[[NSDateFormatter alloc] init];
    
    NSDate *dateNow = [NSDate date];
    
    // get todays day with day formatter and compare to eventDate
    [dayFormatter setDateFormat:@"MMddYYYY"];
    
    NSString *todaysDate = [dayFormatter stringFromDate:[NSDate date]];
    
    // NSLog (@"Todays date is \'%@\' - compare to %@", todaysDate, rootView.eventDate);
    
    BOOL isToday;
    
    if ([todaysDate isEqualToString:self.viewDate]) {
        
        //NSLog(@"it is set to today");
        
        isToday = TRUE;
        
        
    } else {
        
        //NSLog(@"it is NOT set to today");
        nextEventLabel.text = @"Set date to today to see the upcoming event";
        timeToNextEventLabel.text = @"";
        
        isToday = FALSE;
        
        
    }
    
    lastEvent = nil;
    nextEvent = nil;
    
    //float timeFromLastEvent;
    float timeToNextEvent;
    
    // Go through the dayData events one at a time to see which one was last and next
    for (Event *thisEvent in [self.fetchedResultsControllerDetail fetchedObjects]) {
    
        // Create an NSDate variable that can be compared to dateNow
        switch ([dateNow compare:thisEvent.eventNSDate]) {
                
            case NSOrderedSame:
                
                lastEvent = thisEvent;
                //timeFromLastEvent = (long) [dateNow timeIntervalSinceDate:thisEventDate];
                break;
                
            case NSOrderedDescending:
                
                lastEvent = thisEvent;
                //timeFromLastEvent = (long) [dateNow timeIntervalSinceDate:thisEventDate];
                break;
                
            case NSOrderedAscending:
                
                nextEvent = thisEvent;
                timeToNextEvent = (long) [thisEvent.eventNSDate timeIntervalSinceDate:dateNow];
                break;
                
        }
        
        if (nextEvent != nil) {
            break;
        }
        
        
    }
    
    NSMutableString *text = [[NSMutableString alloc] init];
    
    if ((nextEvent != nil)&&(isToday)) {
        
        long hours = (long) timeToNextEvent / 3600;
        long secsLeftover = (long) timeToNextEvent % 3600;
        long minutes = (long) secsLeftover / 60;
        
        // round minutes up
        minutes = minutes + 1;
        
        //NSLog (@"%f - %ld -%ld - %ld", timeToNextEvent, hours, secsLeftover, minutes);
        
        //countdownLabel.font = [UIFont fontWithName:@"Whiteboard Modern" size:20];
        //[text appendString:[NSString stringWithFormat:@"Countdown to next event: %ld hours and %ld minutes", hours, minutes]];
        [text appendString:[NSString stringWithFormat:@"Starts In: "]];
        
        
        //NSLog(@"Countdown to next event: %ld hours and %ld minutes", hours, minutes);
        
        if (hours != 0) {
            
            //NSLog (@"%ld hour", hours);
            [text appendString:[NSString stringWithFormat:@"%ld hour", hours]];
            
            if (hours == 1) {
                
                //NSLog (@" and ");
                [text appendString:[NSString stringWithFormat:@" and "]];
                
                
            } else {
                
                //NSLog (@"s and ");
                [text appendString:[NSString stringWithFormat:@"s and "]];
                
            }
            
        }
        
        [text appendString:[NSString stringWithFormat:@"%ld minutes", minutes]];
        
        // if it's only one minute, remove the 's' from the the end
        
        
        
        nextEventLabel.text = [NSString stringWithFormat:@"Next Event: %@",nextEvent.eventText];
        
        timeToNextEventLabel.text = text;
        
        // whenever the next event changes, add a new alert (remove the last one)
        // at three minutes until the next event, create a notification that will go off in two minutes
        if (currentAlert != nextEvent) {
            
            [[UIApplication sharedApplication] cancelAllLocalNotifications];
            NSLog(@"cancelling previous notifications, setting notification for the next event");
            UILocalNotification* localNotification = [[UILocalNotification alloc] init];
            
            // set to go off one minute before the event, this could be a user setting if added here
            
            localNotification.fireDate = [nextEvent.eventNSDate dateByAddingTimeInterval:-60];
            localNotification.alertBody = [NSString stringWithFormat:@"One minute till event: %@", nextEvent.eventText];
            localNotification.timeZone = [NSTimeZone defaultTimeZone];
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
            
        }
        
        
    }
    
    
    if (nextEvent == nil) {
        
        //NSLog (@"nextEvent is nil, clear out the text");
        
        // if it's today, clear out the label, otherwise it will still say "switch to today"
        if (isToday) {
            
            nextEventLabel.text = @"";
            
        }
        
        // if the frc is empty, add placeholder text
        if ([self.fetchedResultsControllerDetail.fetchedObjects count] == 0) {
            
            timeToNextEventLabel.text = @"Press + to add";
            
        } else {
            
            timeToNextEventLabel.text = @"";
            
        }
        
        
        
    }

    
}


// add delegate methods for tableview and fetchedresultscontroller
#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsControllerDetail sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsControllerDetail sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DetailEventCell"];
    
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
        NSManagedObjectContext *context = [self.fetchedResultsControllerDetail managedObjectContext];
        [context deleteObject:[self.fetchedResultsControllerDetail objectAtIndexPath:indexPath]];
        
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
    Event *event = [self.fetchedResultsControllerDetail objectAtIndexPath:indexPath];
    [event toggleChecked];
    [self configureCheckmarkForCell:cell withEvent:event];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    Event *event = [self.fetchedResultsControllerDetail objectAtIndexPath:indexPath];
    
    if ([event.eventNotes isEqualToString:@""]) {
        
        return 90;
        
    } else {
        
        return 119;
        
    }

}




#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsControllerDetail
{
    if (_fetchedResultsControllerDetail != nil) {
        return _fetchedResultsControllerDetail;
    }
    
    
    NSString *scheduleNameToLoad;
    
    if (self.viewSchedule.scheduleName) {
    
        scheduleNameToLoad = self.viewSchedule.scheduleName;
    
    } else {
        
        scheduleNameToLoad = @"dummy";
        
        
    }
        
    
    NSLog(@"the detail fetched results controller is getting the events for %@", self.viewNSDate);
    
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
    NSPredicate *requestPredicate = [NSPredicate predicateWithFormat:@"(eventDate like %@) AND (schedule.scheduleName like %@)", [Event returnDateString:self.viewNSDate], scheduleNameToLoad];
    
    [fetchRequest setPredicate:requestPredicate];
    
    // Clear out any previous cache
    [NSFetchedResultsController deleteCacheWithName:@"Master"];
    
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsControllerDetail = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsControllerDetail performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsControllerDetail;}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.detailTableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.detailTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.detailTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.detailTableView;
    
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
    [self.detailTableView endUpdates];
}

/*
 // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
 {
 // In the simplest, most efficient, case, reload the table view.
 [self.detailTableView reloadData];
 }
 */

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    
    // here is where we could determine which event is going to be next and then highlight it somehow
    
    // this casts the cell to a EventCell
    EventCell *eventCell = (EventCell *)cell;
    
    // this gets the data from the fetched results
    Event *event = [self.fetchedResultsControllerDetail objectAtIndexPath:indexPath];
    
    // this sets the cell labels
    eventCell.eventTextLabel.text = event.eventText;
    eventCell.eventTimeLabel.text = [Event formatEventTime:event.eventNSDate] ;
    eventCell.eventNotesLabel.text = event.eventNotes;
    
    // thi wraps the test to multiple lines
    eventCell.eventNotesLabel.numberOfLines = 0;
    eventCell.eventNotesLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    // show the end time if default setting useEndTimes is true
    // check to see if we want to use end times, if not don't show those fields
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    if ([preferences boolForKey:@"useEndTimes"]) {
        eventCell.eventEndTimeLabel.text = [Event formatEventTime:event.eventEndNSDate];
    } else {
        eventCell.eventEndTimeLabel.text = @"";
    }
    
    // set the checkmark
    [self configureCheckmarkForCell:cell withEvent:event];
    
}

- (void)configureCheckmarkForCell:(UITableViewCell *)cell withEvent:(Event *)event
{
    
    // this adds a checkmark in the label by the cell if eventChecked is true
    
    EventCell *eventCell = (EventCell *)cell;
    if (event.eventChecked) {
        
        eventCell.eventCheckLabel.text = @"√";
        
    } else {
        
        eventCell.eventCheckLabel.text = @"";
        
    }
}


- (void)updateDetailView {
    
    // update the viewDate variables, reload all the new data, and update the table
    
    self.fetchedResultsControllerDetail = nil;
    [self.detailTableView reloadData];
    
    if (self.viewSchedule == nil) {
        scheduleLabel.text = @"Select Schedule to view Events";
        scheduleField.text = @"";
        // and don't let it be editable
        scheduleField.enabled = NO;
    } else {
        scheduleLabel.text = @"Schedule:";
        scheduleField.text = [NSString stringWithFormat:@"%@", self.viewSchedule.scheduleName];
        scheduleField.enabled = YES;
    }
    
    [self updateTime];
    
}

// UITextField delegate methods
// textfield delegate methods

- (void) textFieldDidBeginEditing:(UITextField *)textField {
    
    NSLog(@"did begin editing");
    
    if (!tap) {
        tap = [[UITapGestureRecognizer alloc]
               initWithTarget:self
               action:@selector(dismissKeyboard)];
    }
    [self.view addGestureRecognizer:tap];
    
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
    
    NSLog(@"did end editing");
    
    [self.view removeGestureRecognizer:tap];
    
    NSLog(@"textfield should return");
    
    // first check to see if they even changed the name
    if ([scheduleField.text isEqualToString:self.viewSchedule.scheduleName]) {
        
        // then they never actually changed the name, return
        
        [scheduleField resignFirstResponder];
        return;
        
    }
    
    if ([textField.text isEqualToString:@""]) {
        
        // NSLog(@"Text field is empty");
        
        UIAlertView *emptyTextAlert;
        
        emptyTextAlert = [[UIAlertView alloc]
                          initWithTitle:@"Please enter a schedule name"
                          message:@""
                          delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
        
        [emptyTextAlert show];
        
        return;
        
    }
    
    // now check to see if there is already a template with that name
    // if so, should I let them overwrite it?
    if ([Schedule scheduleNameExists:scheduleField.text inMOC:self.managedObjectContext]) {
        
        NSLog(@"this schedule exists");
        
        UIAlertView *emptyTextAlert;
        
        emptyTextAlert = [[UIAlertView alloc]
                          initWithTitle:@"A schedule with this name already exists"
                          message:@""
                          delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
        
        //cancelButtonTitle:@"Cancel"
        //otherButtonTitles:@"Replace", @"Merge", Nil];
        
        [emptyTextAlert show];
        
        // put the old name back and resign responder?
        scheduleField.text = self.viewSchedule.scheduleName;
        //[scheduleField resignFirstResponder];
        
        return;
        
    }
    
    self.viewSchedule.scheduleName = scheduleField.text;
    
    // and update the master controller table too
    self.masterViewController.viewSchedule.scheduleName = scheduleField.text;
    
    // do I need to update all the template events too? - yup
    
    for (Event *event in [self.fetchedResultsControllerDetail fetchedObjects]) {
        
        event.schedule = self.viewSchedule;
        
    }
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Error: %@", error);
        abort();
    }
    
    // then update the table?
    self.fetchedResultsControllerDetail = nil;
    [self.detailTableView reloadData];
    
    
    self.masterViewController.fetchedResultsController = nil;
    [self.masterViewController.tableView reloadData];
    
    
}



- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
    
}


-(IBAction)dismissKeyboard {
    
    NSLog(@"dismiss keyboard");
    [self.view endEditing:YES];
    
}



// respond to the alert view regarding existing schedule name

- (void) alertView:(UIAlertView *) alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    
    NSLog(@"clicked button %@", buttonTitle);
    
    
    if ([buttonTitle isEqualToString:@"Merge"]) {
        
        NSLog(@"merge the new data with the existing schedule");
        
        
    } else if ([buttonTitle isEqualToString:@"Replace"]) {
        
        NSLog(@"replace the existing schedule");
        
        // maybe put up another alert that you will be deleting the previous template?
        
    }
    
}


@end
