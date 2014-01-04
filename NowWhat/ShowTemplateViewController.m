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
        
        //NSLog(@"show template base time is %@", self.baseTime);
    }


    //[self setTitle:self.templateToShow.templateName];
    [self setTitle:@"Template"];

    // set the templateNameLabel to the tempateName
    templateNameField.text = self.templateToShow.templateName;

    
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
        //NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
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
            //NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
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
        unmanagedEvent.eventEndTime = lastEditedEvent.eventEndTime;
        
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
    
    // setup the predicate to return just the wanted dat
    NSPredicate *requestPredicate = [NSPredicate predicateWithFormat:@"(template.templateName like %@)", self.templateToShow.templateName];
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
	    //NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsControllerTemplateEvents;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    if (changeIsUserDriven) return;
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    if (changeIsUserDriven) return;

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
    if (changeIsUserDriven) return;

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
    if (changeIsUserDriven) return;

    [self.tableView endUpdates];
}


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
    eventCell.eventNotesView.text = event.eventNotes;
    
    // show the end time if default setting useEndTimes is true
    // check to see if we want to use end times, if not don't show those fields
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    if ([preferences boolForKey:@"useEndTimes"]) {
        eventCell.eventEndTimeLabel.text = [Event formatEventTime:event.eventEndTime];
    } else {
        eventCell.eventEndTimeLabel.text = @"";
    }
    
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
        event.eventEndNSDate = [Event mergeDate:[Event returnDateString:self.viewNSDate] withTime:templateEvent.eventEndTime];
        
    }
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        //NSLog(@"Error: %@", error);
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
    templateEvent.eventEndTime = unmanagedEvent.eventEndTime;
    
    //NSLog (@"adding templateEvent at %@", templateEvent.eventTime);
    //NSLog (@"Text is: %@", templateEvent.eventText);

    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        //NSLog(@"Error: %@", error);
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
    lastEditedEvent.eventEndTime = unmanagedEvent.eventEndTime;
    
}


-(IBAction)dismissKeyboard {
    
    //NSLog(@"dismiss keyboard");
    [self.view endEditing:YES];
    
}


// textfield delegate methods

- (void) textFieldDidBeginEditing:(UITextField *)textField {
    
    //    NSLog(@"did begin editing");
    
    if (!tap) {
        tap = [[UITapGestureRecognizer alloc]
               initWithTarget:self
               action:@selector(dismissKeyboard)];
    }
    [self.view addGestureRecognizer:tap];
    
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
    
    [self.view removeGestureRecognizer:tap];
    
    if ([textField.text isEqualToString:@""]) {
        
        // NSLog(@"Text field is empty");
        
        UIAlertView *emptyTextAlert;
        
        emptyTextAlert = [[UIAlertView alloc]
                          initWithTitle:@"Please enter a template name"
                          message:@""
                          delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
        
        [emptyTextAlert show];

        templateNameField.text = self.templateToShow.templateName;

        return;
        
    }
    
    // now check to see if there is already a template with that name
    // if so, should I let them overwrite it?
    
    // if it's just the same name that is was, don't do anything
    if ([textField.text isEqualToString:self.templateToShow.templateName]) {
        
        [templateNameField resignFirstResponder];
        return;
        
    }
    
    
    if ([Template templateNameExists:templateNameField.text inMOC:self.managedObjectContext]) {
        
        //NSLog(@"this template exists");
        
        UIAlertView *emptyTextAlert;
        
        emptyTextAlert = [[UIAlertView alloc]
                          initWithTitle:@"A template with this name already exists"
                          message:@""
                          delegate:self
                          cancelButtonTitle:@"Cancel"
                          otherButtonTitles:@"Replace", @"Merge", Nil];
        
        [emptyTextAlert show];
        
        return;
        
    }
    
    
    self.templateToShow.templateName = templateNameField.text;
    
    // do I need to update all the template events too? - yup
    
    for (TemplateEvent *templateEvent in [self.fetchedResultsControllerTemplateEvents fetchedObjects]) {
        
        templateEvent.template = self.templateToShow;
        
    }
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        //NSLog(@"Error: %@", error);
        abort();
    }
    
    // then update the table?
    self.fetchedResultsControllerTemplateEvents = nil;
    [self.tableView reloadData];
    
    [textField resignFirstResponder];
    
    return;

}



- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;

}





// respond to the alert view regarding existing template name

- (void) alertView:(UIAlertView *) alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    
    //NSLog(@"clicked button %@", buttonTitle);
    
    if ([buttonTitle isEqualToString:@"Merge"]) {
        
        //NSLog(@"merge the new data with the existing template");
        
        [self mergeTemplate];
        
        return;
        
    } else if ([buttonTitle isEqualToString:@"Replace"]) {
        
        //NSLog(@"replace the existing template");
        
        // maybe put up another alert that you will be deleting the previous template?
        
        UIAlertView *deleteAlert;
        
        deleteAlert = [[UIAlertView alloc]
                          initWithTitle:@"Are you sure you want to delete the old template"
                          message:@""
                          delegate:self
                          cancelButtonTitle:@"Cancel"
                          otherButtonTitles:@"Delete", Nil];
        
        [deleteAlert show];
        
        return;
        
        
    } else if ([buttonTitle isEqualToString:@"Delete"]) {
    
        //NSLog(@"go ahead and delete the existing template");
        
        [self replaceTemplate];
    
        return;
    
    } else if ([buttonTitle isEqualToString:@"Cancel"]) {
        
        //NSLog(@"cancel the action and put the old name back");
        templateNameField.text = self.templateToShow.templateName;
        
        return;
        
    }
    

}


-(void) replaceTemplate {
    
    changeIsUserDriven = YES;
    
    // delete the old template with name self.templateToShow.template name
    // delete the template with name textField.text and save the template events in toShow to
    // the old name
    NSManagedObjectContext *context = [self.fetchedResultsControllerTemplateEvents managedObjectContext];
    
    // first delete previous template
    
    Template *templateToDelete = [Template returnTemplateForName:templateNameField.text inContext:context];
    
    [context deleteObject:templateToDelete];
    // this *should* delete all it's children events too
    
    // now change the name of the current template to show...
    self.templateToShow.templateName = templateNameField.text;
    
    // do I need to update all the template events too? - yup
    
    for (TemplateEvent *templateEvent in [self.fetchedResultsControllerTemplateEvents fetchedObjects]) {
        
        templateEvent.template = self.templateToShow;
        
    }
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        //NSLog(@"Error: %@", error);
        abort();
    }
    
    // then update the table?
    self.fetchedResultsControllerTemplateEvents = nil;
    [self.tableView reloadData];
    
    [templateNameField resignFirstResponder];
    
    changeIsUserDriven = NO;

    
}



-(void) mergeTemplate {

    changeIsUserDriven = YES;
    
    
    // first get the other template
    Template *templateToMerge = [Template returnTemplateForName:templateNameField.text inContext:self.managedObjectContext];
    
    Template *templateToDelete = self.templateToShow;
    
    // update all the template events
    
    for (TemplateEvent *templateEvent in [self.fetchedResultsControllerTemplateEvents fetchedObjects]) {
        
        templateEvent.template = templateToMerge;
        
    }
    
    
    // now delete the current template to show from the context and set the other template to be
    // the one that was shown
    
    ///[self.managedObjectContext deleteObject:self.templateToShow];
    
    self.templateToShow = templateToMerge;
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        //NSLog(@"Error: %@", error);
        abort();
    }
    
    
    [self.managedObjectContext deleteObject:templateToDelete];
    
    if (![self.managedObjectContext save:&error]) {
        //NSLog(@"Error: %@", error);
        abort();
    }
    
    // then update the table
    self.fetchedResultsControllerTemplateEvents = nil;
    
    [self.tableView reloadData];
    
    [templateNameField resignFirstResponder];
    
    changeIsUserDriven = NO;
    
}



// this is deprecated in ios 6, but still needed in 5
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}





@end
