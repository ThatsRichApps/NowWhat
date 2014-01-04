//
//  NowWhatMasterViewController.m
//  NowWhat
//
//  Created by Rich Humphrey on 10/14/13.
//  Copyright (c) 2013 Rich Humphrey. All rights reserved.
//

#import "NowWhatMasterViewController.h"
#define kViewNSDate @"viewNSDate"
#define kViewSchedule @"viewSchedule"
#define kIsLocked @"isLocked"
#define kPassword @"password"

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
        //self.clearsSelectionOnViewWillAppear = NO;
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    // the viewNSDate and viewDate will be passed in from MainScheduleViewController
    // set the viewNSDate as today every this is reloaded now
    //self.viewNSDate = [[NSDate alloc] init];
    //self.viewNSDate = [Event resetToBaseTime:self.viewNSDate];
    
    // When this view is loaded, persist userDefaults for the schedule
    NSUserDefaults *defaults =  [NSUserDefaults standardUserDefaults];
    
    // gte the notification time interval
    //notificationTime =
    
    [defaults setObject:self.viewSchedule.scheduleName forKey:kViewSchedule];
    [defaults synchronize];
    
    if (self.viewSchedule == nil) {
        
        // No schedule was passed in, that's a problem
        // this shouldn't happen, handle it if it does - but how?  pop back to mainschedule viewer?
        
    }
    
    // set the title of the nav controller to the day and date
    // Get the Day for this Schedule
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEEE MM-dd"];
    NSString *dateTitleString = [formatter stringFromDate:self.viewNSDate];
    [self setTitle:dateTitleString];
    
    [self performFetch];
    
    // this should have been already done in the MainSchedule... ?
    // if it's an ipad, setup the detailViewController
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {

    
        //self.detailViewController = (NowWhatDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
        self.detailViewController.viewNSDate = self.viewNSDate;
        self.detailViewController.viewDate = self.viewDate;
        self.detailViewController.viewSchedule = self.viewSchedule;
        self.detailViewController.managedObjectContext = self.managedObjectContext;
        self.detailViewController.masterViewController = self;
        
        //self.detailViewController.fetchedResultsControllerDetail = self.fetchedResultsController;
    
        [self.detailViewController updateDetailView];
    
    } else {
        
        self.detailViewController = nil;
    }
    
    // show the bottom toolbar
    //[self.navigationController setToolbarHidden:NO];
    
    // make sure the navigation bar is opaque
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.toolbar.translucent = NO;
    
    // save the buttons for later if you lock and unlock it
    saveButtonItems = [self.toolbarItems mutableCopy];
    saveAddButton = self.navigationItem.rightBarButtonItem;
    
    scheduleLabel.text = [NSString stringWithFormat:@""];
    scheduleField.text = [NSString stringWithFormat:@"%@", self.viewSchedule.scheduleName];
    
    nextEventLabel.text = @"";
    timeToNextEventLabel.text = @"";
    
    // run once now to initiallize it
    [self updateTime];
    
    // repeat every # seconds - low for testing, up to 30 or so for release
    [NSTimer scheduledTimerWithTimeInterval: 5.0
                                     target: self
                                   selector: @selector(updateTime)
                                   userInfo: nil
                                    repeats: YES];
    
    
    nextEventLabel.text = @"";
    timeToNextEventLabel.text = @"";
    
    self.isLocked = [defaults boolForKey:kIsLocked];
    
    if (self.isLocked) {
    
        self.correctPassword = [defaults integerForKey:kPassword];
        
        [self lockIt:nil withPassword:self.correctPassword];
        
    }
    
    
}



- (void)viewDidAppear:(BOOL)animated
{
    //NSLog(@"view did appear");
    [super viewDidAppear:animated];

}




- (void)viewWillDisappear:(BOOL)animated
{
    //NSLog(@"view will disappear, ta da!");
    [super viewWillDisappear:animated];
    
    if ([self isMovingFromParentViewController]){
        //specific stuff for being popped off stack
        NSLog(@"back pressed, clear schedule variable");
        
        NSUserDefaults *defaults =  [NSUserDefaults standardUserDefaults];
        
        // when you go back to schedule, set the persisted schedule to nil
        [defaults setObject:nil forKey:kViewSchedule];
        [defaults synchronize];
    
        // should I also reset the detail view controller?
        self.detailViewController.viewSchedule = nil;
        [self.detailViewController updateDetailView];
        
        
    }
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    //NSLog(@"view did disappear");
    [super viewDidDisappear:animated];
   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    self.fetchedResultsController = nil;

}

- (void)viewDidUnload {
    NSLog(@"view did unload");
    self.fetchedResultsController = nil;
}


-(void) updateTime {
    
    //NSLog(@"Update the time and check Now What?");
    
    Event *currentAlert = nextEvent;
    
    NSDateFormatter *dayFormatter =[[NSDateFormatter alloc] init];
    
    NSDate *dateNow = [NSDate date];
    
    // get todays day with day formatter and compare to eventDate
    [dayFormatter setDateFormat:@"yyyyMMdd"];
    
    NSString *todaysDate = [dayFormatter stringFromDate:[NSDate date]];
    
    // NSLog (@"Todays date is \'%@\' - compare to %@", todaysDate, rootView.eventDate);
    
    BOOL isToday;
    
    if ([todaysDate isEqualToString:self.viewDate]) {
        
        //NSLog(@"it is set to today");
        
        isToday = TRUE;
        
        
    } else {
        
        //NSLog(@"it is NOT set to today");
        // Only show the date
        
        
        nextEventLabel.text = @"Set date to today to see next event";
        timeToNextEventLabel.text = @"";
        
        isToday = FALSE;
        
        
    }
    
    lastEvent = nil;
    nextEvent = nil;
    
    //float timeFromLastEvent;
    float timeToNextEvent;
    
    // Go through the dayData events one at a time to see which one was last and next
    for (Event *thisEvent in [self.fetchedResultsController fetchedObjects]) {
        
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
        
        nextEventLabel.text = [NSString stringWithFormat:@"Next Event: %@",nextEvent.eventText];
        timeToNextEventLabel.text = text;
        
        // whenever the next event changes, add a new alert (remove the last one)
        // at three minutes until the next event, create a notification that will go off in two minutes
        //if ((hours == 0)&&(minutes == 3)) {
        if (currentAlert != nextEvent) {
            
            
            // check the user default settings for for often to notify the user
            
            
            NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
            
            NSInteger notifyBeforeTime = [preferences integerForKey:@"notificationTime"];
            
            NSLog(@"setting notification for %i minutes before the next event", notifyBeforeTime);
            
            if (notifyBeforeTime !=0) {
            
                [[UIApplication sharedApplication] cancelAllLocalNotifications];
                UILocalNotification* localNotification = [[UILocalNotification alloc] init];
                localNotification.fireDate = [nextEvent.eventNSDate dateByAddingTimeInterval: -60 * notifyBeforeTime];
                
                // vary the message based upon the notifyBeforeTime
                NSString *alertText;
                if (notifyBeforeTime == 1) {
                    alertText = [NSString stringWithFormat:@"1 minute till event: %@", nextEvent.eventText];
                } else {
                    alertText = [NSString stringWithFormat:@"%ld minutes till event: %@", (long)notifyBeforeTime, nextEvent.eventText];
                }
                localNotification.alertBody = alertText;
                
                //localNotification.alertBody = [NSString stringWithFormat:@"One minute till event: %@", nextEvent.eventText];
                localNotification.timeZone = [NSTimeZone defaultTimeZone];
                [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
 
            
            }
        }
    }

    if (nextEvent == nil) {
        
        //NSLog (@"nextEvent is nil, clear out the text");
        
        
        // if it's today, clear out the label, otherwise it will say "switch to today"
        if (isToday) {
        
            nextEventLabel.text = @"";
            
        }
        
        // if the frc is empty, add placeholder text
        if ([self.fetchedResultsController.fetchedObjects count] == 0) {
        
            timeToNextEventLabel.text = @"Press + to add new event";
            
        } else {
            
            timeToNextEventLabel.text = @"";
            
        }
        
    }
    
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
    
    Event *event = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    [self performSegueWithIdentifier:@"EditEvent" sender:event];
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
    
    if (_isLocked) {
        return NO;
    } else {
        return YES;
    }
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

    /*
    // this updates the detail controller when a row is selected.  Not sure we want to do that
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        self.detailViewController.detailItem = object;
    }
    */
    
    // toggle the checkmark on the detail view item also here
    
    
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([[segue identifier] isEqualToString:@"AddEvent"]) {

        // start the edit/add event controller, adding a new one for the date and schedule
        UINavigationController *navigationController = segue.destinationViewController;
        EditEventViewController *controller = (EditEventViewController *)navigationController.topViewController;
        
        controller.baseTime = self.viewNSDate;
        controller.eventSchedule = self.viewSchedule;
        controller.delegate = self;
        
    }
    if ([[segue identifier] isEqualToString:@"EditEvent"]) {

        // keep track of the event that is sent to be edited and launch the edit event controller, changes are
        // handled by delegates
        
        lastEditedEvent = sender;

        UINavigationController *navigationController = segue.destinationViewController;
        EditEventViewController *controller = (EditEventViewController *)navigationController.topViewController;
        
        controller.baseTime = self.viewNSDate;
        
        UnmanagedEvent *unmanagedEvent = [[UnmanagedEvent alloc] init];
        
        unmanagedEvent.eventText = lastEditedEvent.eventText;
        unmanagedEvent.eventNotes = lastEditedEvent.eventNotes;
        unmanagedEvent.eventTime = lastEditedEvent.eventNSDate;
        unmanagedEvent.eventEndTime = lastEditedEvent.eventEndNSDate;
        
        controller.eventToEdit = unmanagedEvent;
        controller.delegate = self;

        // pass in the isLocked variable, allows for viewing but not actual editing of the event
        controller.isLocked = self.isLocked;
        
    }

    if ([[segue identifier] isEqualToString:@"ChangeDay"]) {
        
        // use this if the view is embedded in a navigation controller
        UINavigationController *navigationController = segue.destinationViewController;
        ChangeDateViewController *controller = (ChangeDateViewController *)navigationController.topViewController;
        
        controller.selectedDate = self.viewNSDate;
        // the changedateviewcontroller delegate implements changedatepicker and updates the viewDate
        controller.delegate = self;
        //NSLog(@"the sent date is %@", self.viewNSDate);
        
    }

    if ([[segue identifier] isEqualToString:@"ListTemplates"]) {
        
        // use this when the view is popped onto the controller
        TemplateListViewController *controller = (TemplateListViewController *)[segue destinationViewController];
        controller.managedObjectContext = self.managedObjectContext;
        controller.viewNSDate = self.viewNSDate;
        controller.viewSchedule = self.viewSchedule;
        
    }

    if ([[segue identifier] isEqualToString:@"SaveTemplate"]) {
        
        SaveTemplateViewController *controller = (SaveTemplateViewController *)[segue destinationViewController];
        // send the data to the save template in the form of an array
        controller.templateEvents = [self loadEvents];
        controller.templateNameForField = self.title;
        controller.managedObjectContext = self.managedObjectContext;
        
    }

    
    if ([[segue identifier] isEqualToString:@"PasswordLock"]) {
        
        PasswordViewController *controller = (PasswordViewController *)[segue destinationViewController];
        controller.isLocked = self.isLocked;
        controller.correctPassword = self.correctPassword;
        controller.delegate = self;
        
    }
    
}

-(NSMutableArray*) loadEvents {
    
    
    // this creates an array of unmanaged events to be sent to the savetemplateviewcontroller
    // do I need to create a whole new fetch request here?? seems like
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];

    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"eventNSDate" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];

    // setup the predicate to return just the wanted date and schedule
    NSPredicate *requestPredicate = [NSPredicate predicateWithFormat:@"(eventDate like %@) AND (schedule.scheduleName like %@)", [Event returnDateString:self.viewNSDate], self.viewSchedule.scheduleName];
    
    //NSLog(@"predicate:%@", requestPredicate.predicateFormat);
    
    [fetchRequest setPredicate:requestPredicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (fetchedObjects == nil) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    
    // I think I should probably change these events into template events before
    // I send then on to the saveTemplateView
    
    NSMutableArray *unmanagedEventsArray = [[NSMutableArray alloc] init];
    
    for (Event *thisEvent in fetchedObjects) {
        
        // create an array of unmanaged events for sending to save template
        UnmanagedEvent *newUnmanagedEvent = [[UnmanagedEvent alloc] init];
        newUnmanagedEvent.eventText = thisEvent.eventText;
        
        // strip off the date from the eventNSDate
        newUnmanagedEvent.eventTime = [Event normalizeDay:thisEvent.eventNSDate];
        newUnmanagedEvent.eventEndTime = [Event normalizeDay:thisEvent.eventEndNSDate];
        
        newUnmanagedEvent.eventNotes = thisEvent.eventNotes;
        [unmanagedEventsArray addObject:newUnmanagedEvent];
        
    }
    
    return unmanagedEventsArray;

}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    
    NSLog(@"the fetched results controller is getting the events for %@", self.viewNSDate);
    
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
    
    // setup the predicate to return just the wanted date and schedule
    NSPredicate *requestPredicate = [NSPredicate predicateWithFormat:@"(eventDate like %@) AND (schedule.scheduleName like %@)", [Event returnDateString:self.viewNSDate], self.viewSchedule.scheduleName];
    NSLog(@"predicate:%@", requestPredicate);
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
    
    // manually set the delegate?
    
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
    
    eventCell.eventTimeLabel.text = [NSString stringWithFormat:@"%@",[Event formatEventTime:event.eventNSDate]];
    
    eventCell.eventNotesLabel.text = event.eventNotes;
    
    //eventCell.eventNotesLabel.numberOfLines = 2;
    //[eventCell.eventNotesLabel sizeToFit];
    
    eventCell.eventNotesLabel.numberOfLines = 0;
    eventCell.eventNotesLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    //eventCell.eventNotesView.text = event.eventNotes;

    
    // show the end time if default setting useEndTimes is true
    // check to see if we want to use end times, if not don't show those fields
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    
    if ([preferences boolForKey:@"useEndTimes"]) {
        
        eventCell.eventEndTimeLabel.text = [Event formatEventTime:event.eventEndNSDate];
        // these lines make it top left justified
        //eventCell.eventEndTimeLabel.numberOfLines = 2;
        //[eventCell.eventEndTimeLabel sizeToFit];

    } else {
        
        eventCell.eventEndTimeLabel.text = @"";
        
    }
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        cell.accessoryType =  UITableViewCellAccessoryDetailButton;
    } else {
        cell.accessoryType =  UITableViewCellAccessoryDetailDisclosureButton;
    }
    
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


#pragma mark - CategoryPickerViewControllerDelegate
- (void)changeDatePicker:(ChangeDateViewController *)controller didChangeDate:(NSDate *)newDate {
    
    // update the viewDate variables, reload all the new data, and update the table
    
    
    nextEventLabel.text = @"";
    timeToNextEventLabel.text = @"";
    
    self.viewNSDate = [Event resetToBaseTime:newDate];
    self.viewDate = [Event returnDateString:newDate];
    
    NSLog(@"didChangDate - the new date is %@", self.viewNSDate);
    // update the user defaults for next time the app is loaded
    NSUserDefaults *defaults =  [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:self.viewNSDate forKey:kViewNSDate];
    [defaults synchronize];
    
    // reset the title of the nav controller to the new day and date
    // Get the EEEE - day of the week for this Schedule
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEEE MM-dd"];
    NSString *dateTitleString = [formatter stringFromDate:self.viewNSDate];
    [self setTitle:dateTitleString];

    self.fetchedResultsController = nil;
    [self.tableView reloadData];
    
    // send the date change up the line
    [self.delegate changeDatePicker:nil didChangeDate:newDate];
    
    
    // and to the detail view controller
    if (self.detailViewController != nil) {
        
        self.detailViewController.viewNSDate = self.viewNSDate;
        self.detailViewController.viewDate = self.viewDate;
        
        [self.detailViewController updateDetailView];
        
    }
    
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
    event.eventEndNSDate = unmanagedEvent.eventEndTime;
    event.eventDate = [Event returnDateString:unmanagedEvent.eventTime];
    event.eventChecked = NO;
    event.schedule = self.viewSchedule;

    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Error: %@", error);
        abort();
    }
    
    // then update the table?
    //self.fetchedResultsController = nil;
    //[self.tableView reloadData];
    
    // update the detail view with what's next
    [self.detailViewController updateDetailView];
    
}

- (void)editEventView:(EditEventViewController *)controller editEvent:(UnmanagedEvent *)unmanagedEvent;
{

    // edit the info for the selected event
    //NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    //Event *event = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    
    lastEditedEvent.eventText = unmanagedEvent.eventText;
    lastEditedEvent.eventNotes = unmanagedEvent.eventNotes;
    lastEditedEvent.eventNSDate = unmanagedEvent.eventTime;
    lastEditedEvent.eventEndNSDate = unmanagedEvent.eventEndTime;
    lastEditedEvent.eventDate = [Event returnDateString:unmanagedEvent.eventTime];
    
    // then update the context so that it gets saved
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Error: %@", error);
        abort();
    }
    
    // update the detail view with what's next
    [self.detailViewController updateDetailView];
}


#pragma mark - PasswordViewControllerDelegate


- (void)lockIt:(PasswordViewController *)controller withPassword:(int)newPassword {
    
    _isLocked = YES;
    
    // get all the toolbar items and navbar items and set to nil ??? we do this in viewDidLoad now
    //NSMutableArray *items = [self.toolbarItems mutableCopy];
    
    // I don't know if we need to set it to nil before we reset it?
    //[self setToolbarItems:nil];
    
    // remove the top NavBar items
    self.navigationItem.hidesBackButton = YES;
    [self.navigationItem setRightBarButtonItem:nil];
    
    // just add the unlock button
    // Configure the Bottom ToolBar
    UIBarButtonItem *leftSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *lockButton = [[UIBarButtonItem alloc]
                                   initWithImage:[UIImage imageNamed:@"line__0000s_0082_lock"]
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(clickedLockButton:)];
    
    
    [self setToolbarItems:@[leftSpace, lockButton]];
    
    // we want the cells to be selectable now for the checkmark feature
    //self.tableView.allowsSelection = NO; // Keeps cells from being selectable
    
    _correctPassword = newPassword;
    
    // now persist isLocked and the password
    NSUserDefaults *defaults =  [NSUserDefaults standardUserDefaults];
    
    [defaults setInteger:self.correctPassword forKey:kPassword];
    [defaults setBool:self.isLocked forKey:kIsLocked];
    [defaults synchronize];
    
    scheduleField.enabled = NO;
    [self.detailViewController lockIt];

    
}


- (void)unlockIt:(PasswordViewController *)controller withPassword:(int)newPassword {
    
    _isLocked = NO;
    _correctPassword = 0;
    
    self.navigationItem.hidesBackButton = NO;
    
    // add the buttons here
    [self setToolbarItems:saveButtonItems];
    [self.navigationItem setRightBarButtonItem:saveAddButton];
    
    self.tableView.allowsSelection = YES; // Lets cells from be selectable

    // now persist isLocked and the password
    NSUserDefaults *defaults =  [NSUserDefaults standardUserDefaults];
    
    [defaults setInteger:-1 forKey:kPassword];
    [defaults setBool:self.isLocked forKey:kIsLocked];
    [defaults synchronize];

    scheduleField.enabled = YES;
    
    [self.detailViewController unlockIt];
    
    
}


-(void) clickedLockButton:(id)sender{

    // NSLog(@"clicked lock template button");
    
    // set lock bool to true
    // NSLog(@"clicked lock button");
    
    //load password view
    PasswordViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"PasswordView"];
    // send the data to the save template in the form of an array
    controller.isLocked = self.isLocked;
    controller.correctPassword = self.correctPassword;
    controller.delegate = self;
    
    [self.navigationController presentModalViewController:controller animated:YES];
    
}


-(void) printSchedule {
    
    NSLog(@"clicked print button");
    
    UIPrintInteractionController *pic = [UIPrintInteractionController sharedPrintController];
    
    UIPrintInfo *printInfo = [UIPrintInfo printInfo];
    printInfo.outputType = UIPrintInfoOutputGeneral;
    printInfo.duplex = UIPrintInfoDuplexNone;
    
    printInfo.jobName = [NSString stringWithFormat:@"Schedule for %@", self.title];
    
    pic.printInfo = printInfo;
    
    // adding this may help to speed it up
    pic.showsPageRange = NO;
    
    // Here is all the html data for the printout page
    
    NSMutableString *htmlString = [[NSMutableString alloc] init];
    
    // Start the html code for the print output
    [htmlString appendString:@"<html><head><style>body{background-color:transparent;}</style></head><body><font size=\"4\" face=\"Chalkboard SE\">"];
    
    // Show the time of day as well as the date
    NSDateFormatter *formatter =[[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:@"EEEE, MM/dd"];
    [htmlString appendString:[formatter stringFromDate:self.viewNSDate]];
    [htmlString appendString:@"<br><br>"];
    
    for (Event *eventItem in [self.fetchedResultsController fetchedObjects]) {
        
        [htmlString appendString:[Event formatEventTime:eventItem.eventNSDate]];
        [htmlString appendString:@" - "];
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"useEndTimes"]) {
            
            [htmlString appendString:[Event formatEventTime:eventItem.eventEndNSDate]];
            [htmlString appendString:@"<br>"];
            
        }
        
        [htmlString appendString:eventItem.eventText];
        
        if (![eventItem.eventNotes isEqualToString:@""]) {
            
            [htmlString appendString:@"<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"];
            
            
            NSString *formattedString = eventItem.eventNotes;
            formattedString = [formattedString stringByReplacingOccurrencesOfString:@"\n"
                                                                         withString:@"<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"];
            [htmlString appendString:formattedString];
            
        }
        
        [htmlString appendString:@"<br>"];
        
        
    }
    
    // Finish the html statement and print
    
    [htmlString appendString: @"</body></html>"];
    
    UIMarkupTextPrintFormatter *htmlFormatter = [[UIMarkupTextPrintFormatter alloc]
                                                 initWithMarkupText:htmlString];
    htmlFormatter.startPage = 0;
    htmlFormatter.contentInsets = UIEdgeInsetsMake(72.0, 72.0, 72.0, 72.0); // 1 inch margins
    htmlFormatter.maximumContentWidth = 6 * 72.0;
    pic.printFormatter = htmlFormatter;
    pic.showsPageRange = YES;
    
    void (^completionHandler)(UIPrintInteractionController *, BOOL, NSError *) =
    ^(UIPrintInteractionController *printController, BOOL completed, NSError *error) {
        if (!completed && error) {
            NSLog(@"Printing could not complete because of error: %@", error);
        }
    };
    
    // the print button is delayed for a time, adding a forced delay could actually speed it up
    //[NSThread sleepForTimeInterval:2.0];
    
    [pic presentAnimated:YES completionHandler:completionHandler];
    
    
    /*
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [pic presentFromBarButtonItem:self animated:YES completionHandler:completionHandler];
    } else {
        [pic presentAnimated:YES completionHandler:completionHandler];
    }
    */
    

}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}


-(IBAction)dismissKeyboard {
    
    NSLog(@"dismiss keyboard");
    [self.view endEditing:YES];
    
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
    
    // do I need to update all the template events too? - yup
    
    for (Event *event in [self.fetchedResultsController fetchedObjects]) {
        
        event.schedule = self.viewSchedule;
        
    }
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Error: %@", error);
        abort();
    }
    
    // then update the table?
    self.fetchedResultsController = nil;
    [self.tableView reloadData];
    
}



- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;

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

/*
// This method is for importing a schedule file via email
- (void)handleOpenURL:(NSURL *)url {
    
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    NSLog(@"import user data here in master view controller");
    
}
*/

- (IBAction)shareButtonClicked {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"Share Schedule"
                                  delegate:self
                                  cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:@"Mail"
                                  otherButtonTitles:@"Print",nil];
    [actionSheet showFromToolbar:self.navigationController.toolbar];
    
}




//this is the action sheet for the share button
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == [actionSheet cancelButtonIndex]) return;
    
    if (buttonIndex == 0) {
        
        //NSLog(@"mail button");
        [self mailData];
        
    }
    if (buttonIndex == 1) {
        
        //NSLog(@"print button");
        [self printSchedule];
        
    }
}


- (void)mailData {
    
    if ([MFMailComposeViewController canSendMail]) {
        
        // first get the data that needs to be emailed, then create a temporary file
        
        //NSString *textFileContentsString = @"some data, some more data, yet more data";
        //NSData *textFileContentsData = [textFileContentsString dataUsingEncoding:NSASCIIStringEncoding];
        
        // create a JSON model from the day data given viewSchedule and viewNSDate
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        // Edit the entity name as appropriate.
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        
        // Edit the sort key as appropriate.
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"eventNSDate" ascending:YES];
        NSArray *sortDescriptors = @[sortDescriptor];
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        // setup the predicate to return just the wanted date and schedule
        NSPredicate *requestPredicate = [NSPredicate predicateWithFormat:@"(eventDate like %@) AND (schedule.scheduleName like %@)", [Event returnDateString:self.viewNSDate], self.viewSchedule.scheduleName];
        
        //NSLog(@"predicate:%@", requestPredicate.predicateFormat);
        
        [fetchRequest setPredicate:requestPredicate];
        
        NSError *error = nil;
        NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        if (fetchedObjects == nil) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
        NSMutableArray * eventsArray = [[NSMutableArray alloc] init];
        
        for (Event *thisEvent in fetchedObjects) {
            
            NSMutableDictionary *fields = [NSMutableDictionary dictionary];
            
            fields[@"eventText"] = thisEvent.eventText;
            fields[@"eventNotes"] = thisEvent.eventNotes;
            fields[@"eventNSDate"] = [Event JSONEventTime:thisEvent.eventNSDate];
            fields[@"eventEndNSDate"] = [Event JSONEventTime:thisEvent.eventEndNSDate];
            fields[@"scheduleName"] = self.viewSchedule.scheduleName;
            
            [eventsArray addObject:fields];
            
        }
        
        NSError *JSONerror;
        NSData *JSONData = [NSJSONSerialization dataWithJSONObject:eventsArray options:kNilOptions error:&JSONerror];
        
        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
        [picker setSubject:@"Now What Schedule"];
        
        [picker addAttachmentData:JSONData mimeType:@"application/nowwhat" fileName:@"nowwhatdata.nwf"];
        
        
        [picker setToRecipients:@[]];
        
        
        NSString *htmlEvents = [self formatToHTML];
        
        
        [picker setMessageBody:[NSString stringWithFormat:@"Here is my schedule.  From your iOS device, you can tap the file below to open in your copy of \"Now What\".<br>%@<br>Don't have Now What? - get it in the app store! <a href=\"https://itunes.apple.com/us/app/now-what/id434244026?mt=8&uo=4\" target=\"itunes_store\">Now What?</a>", htmlEvents] isHTML:YES];
        
        //[picker setMessageBody:[[NSString alloc] initWithData:JSONData encoding:NSUTF8StringEncoding] isHTML:NO];
        
        [picker setMailComposeDelegate:self];
        
        // the line below is added for ipad funcitonality
        picker.modalPresentationStyle = UIModalPresentationPageSheet;
        [self presentModalViewController:picker animated:YES];
        
    } else {
        
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Your device doesn't support mail compose"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
        
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved: you saved the email message in the drafts folder.");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
            break;
        default:
            NSLog(@"Mail not sent.");
            break;
    }
    // Remove the mail view
    [self dismissModalViewControllerAnimated:YES];
}

-(NSString *) formatToHTML {
    
    NSLog(@"formatting events for html output");
    
    // Here is all the html data for the printout page
    
    NSMutableString *htmlString = [[NSMutableString alloc] init];
    
    // Start the html
    [htmlString appendString:@"<html><head><style>body{background-color:transparent;}</style></head><body><font size=\"4\" face=\"Chalkboard SE\">"];
    
    // Show the time of day as well as the date
    NSDateFormatter *formatter =[[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:@"EEEE, MM/dd"];
    [htmlString appendString:[formatter stringFromDate:self.viewNSDate]];
    [htmlString appendString:@"<br><br>"];
    
    for (Event *eventItem in [self.fetchedResultsController fetchedObjects]) {
        
        [htmlString appendString:[Event formatEventTime:eventItem.eventNSDate]];
        [htmlString appendString:@" - "];
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"useEndTimes"]) {
            
            [htmlString appendString:[Event formatEventTime:eventItem.eventEndNSDate]];
            [htmlString appendString:@" - "];
            
        }
        
        [htmlString appendString:eventItem.eventText];
        
        if (![eventItem.eventNotes isEqualToString:@""]) {
            
            // indent the notes with 5 spaces to start and on every \n (carriage return)
            [htmlString appendString:@"<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"];
            
            NSString *formattedString = eventItem.eventNotes;
            formattedString = [formattedString stringByReplacingOccurrencesOfString:@"\n"
                                                                         withString:@"<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"];
            [htmlString appendString:formattedString];
            
        }
        
        [htmlString appendString:@"<br>"];
        
        
    }
    
    // Finish the html statement and print
    
    [htmlString appendString: @"</body></html>"];
    
    return htmlString;
    
}


            
@end
