//
//  SaveTemplateViewController.m
//  NowWhat
//
//  Created by Rich Humphrey on 10/21/13.
//  Copyright (c) 2013 Rich Humphrey. All rights reserved.
//

#import "SaveTemplateViewController.h"

@interface SaveTemplateViewController ()

@end

@implementation SaveTemplateViewController {
    
    UnmanagedEvent *lastEditedEvent;

}




- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = NO;
    
    // initiallize baseTime to viewDate at 8am, right!
    // right now it's set to current time
    if (self.baseTime == nil) {
        
        self.baseTime = [NSDate date];
        self.baseTime = [Event normalizeDay:self.baseTime];
        self.baseTime = [Event resetToBaseTime:self.baseTime];
        NSLog(@"save template base time is %@", self.baseTime);

    }
    
    // if a template name is passed in to this view, populate the templateNameField
    
    templateNameField.text = self.templateNameForField;
    
    if (self.templateEvents == nil) {
        
        self.templateEvents = [[NSMutableArray alloc] init];
        
    }
        
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
 
    EventCell *eventCell = (EventCell *)cell;
    UnmanagedEvent *event = (self.templateEvents)[indexPath.row];
    
    eventCell.eventTextLabel.text = event.eventText;
    eventCell.eventTimeLabel.text = [Event formatEventTime:event.eventTime];
    eventCell.eventNotesLabel.text = event.eventNotes;
    
    // show the end time if default setting useEndTimes is true
    // check to see if we want to use end times, if not don't show those fields
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    if ([preferences boolForKey:@"useEndTimes"]) {
        eventCell.eventEndTimeLabel.text = [Event formatEventTime:event.eventEndTime];
    } else {
        eventCell.eventEndTimeLabel.text = @"";
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.templateEvents count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SaveTemplateCell"];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
    
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // Delete the row from the data source
        [[self templateEvents] removeObjectAtIndex:[indexPath row]];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
     // Return NO if you do not want the item to be re-orderable.
     return NO;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // this is usually in the prepare for segue, but since it's not a nav controller, I don't think that works
    
            
    // Send the EditTemplateEventViewController the appropriate event that needs editing
    //NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    //NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    UnmanagedEvent *event = (self.templateEvents)[indexPath.row];
    //TemplateEvent *templateEvent;
    
//    UINavigationController *navigationController = segue.destinationViewController;
//    EditTemplateEventViewController *controller = (EditTemplateEventViewController *)navigationController.topViewController;
//    controller.managedObjectContext = self.managedObjectContext;
//    controller.templateEventToEdit = templateEvent;
    //controller.delegate = self;
    NSLog(@"the event selected is %@", event.eventText);
            
            
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
        NSIndexPath *indexPath = [saveTableView indexPathForCell:sender];
        lastEditedEvent = (self.templateEvents)[indexPath.row];
        
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
    
    if ([[segue identifier] isEqualToString:@"InfoSaveTemplates"]) {
        
        UINavigationController *navigationController = segue.destinationViewController;
        MainInfoViewController *controller = (MainInfoViewController *)navigationController;
        controller.callingView = @"InfoSaveTemplates";
        
    }
}


- (IBAction)cancel
{
    
    // clear out template events?
    
    [[self navigationController] popViewControllerAnimated:YES];

}
- (IBAction)save

    {
    if ([templateNameField.text isEqualToString:@""]) {
        
        // NSLog(@"Text field is empty");
        
        UIAlertView *emptyTextAlert;
        
        emptyTextAlert = [[UIAlertView alloc]
                          initWithTitle:@"Please enter a template name"
                          message:@""
                          delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
        
        [emptyTextAlert show];
        
        return;
        
    }

    // now check to see if there is already a template with that name
    // if so, should I let them overwrite it?
        
    if ([Template templateNameExists:templateNameField.text inMOC:self.managedObjectContext]) {
            
        NSLog(@"this template exists");
            
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
        
    // Add these events to the template database
    // do error checking and save to managedObjectContext
    Template *template = nil;
        
    template = [NSEntityDescription insertNewObjectForEntityForName:@"Template" inManagedObjectContext:self.managedObjectContext];
        
    template.templateName = templateNameField.text;
    template.templateListOrder = [Template getNextTemplateOrderInMOC:self.managedObjectContext];
    
        
    // Now go through all the events in the list and add them to the TemplateEvents entity
        
    for (UnmanagedEvent *event in self.templateEvents) {
        
        TemplateEvent *templateEvent;
        templateEvent = [NSEntityDescription insertNewObjectForEntityForName:@"TemplateEvent" inManagedObjectContext:self.managedObjectContext];
        
        templateEvent.eventText = event.eventText;
        templateEvent.eventNotes = event.eventNotes;
        templateEvent.template = template;
        
        // strip the date off of eventNSDate and just save the time
        templateEvent.eventTime = event.eventTime;
        templateEvent.eventEndTime = event.eventEndTime;
        
            
    }
        
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Error: %@", error);
        abort();
    }
        
    [[self navigationController] popViewControllerAnimated:YES];

}


// respond to the alert view regarding existing template name

- (void) alertView:(UIAlertView *) alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    
    //NSLog(@"clicked button %@", buttonTitle);
    
    if ([buttonTitle isEqualToString:@"Merge"]) {
        
        NSLog(@"merge the new data with the existing template");
        
        [self mergeTemplate];
        
        return;
        
    } else if ([buttonTitle isEqualToString:@"Replace"]) {
        
        NSLog(@"replace the existing template");
        
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
        
        NSLog(@"go ahead and delete the existing template");
        
        [self replaceTemplate];
        
        return;
        
    }
    
}


-(void) replaceTemplate {
    
    // delete the old template with name self.templateToShow.template name
    // delete the template with name textField.text and save the template events in toShow to
    // the old name
    // first delete previous template
    
    Template *templateToDelete = [Template returnTemplateForName:templateNameField.text inContext:self.managedObjectContext];
    
    // save it's list order
    NSNumber *listOrder = templateToDelete.templateListOrder;
    
    [self.managedObjectContext deleteObject:templateToDelete];
    // this *should* delete all it's children events too
    
    // now create a new template
    // Add these events to the template database
    // do error checking and save to managedObjectContext
    Template *template = nil;
    
    template = [NSEntityDescription insertNewObjectForEntityForName:@"Template" inManagedObjectContext:self.managedObjectContext];
    
    template.templateName = templateNameField.text;
    template.templateListOrder = listOrder;
    
    // Now go through all the events in the list and add them to the TemplateEvents entity
    
    for (UnmanagedEvent *event in self.templateEvents) {
        
        TemplateEvent *templateEvent;
        templateEvent = [NSEntityDescription insertNewObjectForEntityForName:@"TemplateEvent" inManagedObjectContext:self.managedObjectContext];
        
        templateEvent.eventText = event.eventText;
        templateEvent.eventNotes = event.eventNotes;
        templateEvent.template = template;
        
        // strip the date off of eventNSDate and just save the time
        templateEvent.eventTime = event.eventTime;
        templateEvent.eventEndTime = event.eventEndTime;
        
    }
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Error: %@", error);
        abort();
    }

    // then return to the previous view
    [[self navigationController] popViewControllerAnimated:YES];
    
}



-(void) mergeTemplate {
    
    // first get the other template
    Template *templateToMerge = [Template returnTemplateForName:templateNameField.text inContext:self.managedObjectContext];
    
    
    
    
    // Now go through all the events in the list and add them to the TemplateEvents entity for the merged template
    
    for (UnmanagedEvent *event in self.templateEvents) {
        
        TemplateEvent *templateEvent;
        templateEvent = [NSEntityDescription insertNewObjectForEntityForName:@"TemplateEvent" inManagedObjectContext:self.managedObjectContext];
        
        templateEvent.eventText = event.eventText;
        templateEvent.eventNotes = event.eventNotes;
        templateEvent.template = templateToMerge;
        
        // strip the date off of eventNSDate and just save the time
        templateEvent.eventTime = event.eventTime;
        templateEvent.eventEndTime = event.eventEndTime;
        
        
        
    }
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Error: %@", error);
        abort();
    }
    
    // then return to the previous view
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
    UnmanagedEvent *newEvent = [[UnmanagedEvent alloc] init];
    
    newEvent.eventText = unmanagedEvent.eventText;
    newEvent.eventNotes = unmanagedEvent.eventNotes;
    
    // strip the date off of unmanagedEvent.eventTime
    newEvent.eventTime = unmanagedEvent.eventTime;
    newEvent.eventEndTime = unmanagedEvent.eventEndTime;
    
    NSLog (@"adding templateEvent at %@", newEvent.eventTime);
    NSLog (@"Text is: %@", newEvent.eventText);
    
    // add a new object to the templateEvents NSMutableArray and update the table
    // I'm also going to have to re-Sort the events based upon the time
    
    [self.templateEvents addObject:newEvent];
    
    
    // need to sort dayData and redraw table
    NSSortDescriptor *timeDescriptor;
    timeDescriptor = [[NSSortDescriptor alloc] initWithKey:@"eventTime" ascending:YES];
    NSArray *sortByTimeDescriptors = @[timeDescriptor];
    NSArray *sortedArray = [self.templateEvents sortedArrayUsingDescriptors:sortByTimeDescriptors];
    
    [self.templateEvents removeAllObjects];
    
    [self.templateEvents addObjectsFromArray:sortedArray];
    
    [saveTableView reloadData];
    
    
}

- (void)editEventView:(EditEventViewController *)controller editEvent:(UnmanagedEvent *)unmanagedEvent;
{
    
    // edit the info for the selected event
    
    lastEditedEvent.eventText = unmanagedEvent.eventText;
    lastEditedEvent.eventNotes = unmanagedEvent.eventNotes;
    
    // strip the date off of unmanagedEvent.eventTime
    lastEditedEvent.eventTime = unmanagedEvent.eventTime;
    lastEditedEvent.eventEndTime = unmanagedEvent.eventEndTime;
    
    [saveTableView reloadData];
    
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
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    // This closes the keyboard on done
    
    [textField resignFirstResponder];
    
    return YES;
}


-(IBAction)dismissKeyboard {
    
    NSLog(@"dismiss keyboard");
    [self.view endEditing:YES];
    
}

// this is deprecated in ios 6, but still needed in 5
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}


@end
