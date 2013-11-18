//
//  NowWhatDetailViewController.m
//  NowWhat
//
//  Created by Rich Humphrey on 10/14/13.
//  Copyright (c) 2013 Rich Humphrey. All rights reserved.
//

#import "NowWhatDetailViewController.h"

@interface NowWhatDetailViewController () {
    
    Event *lastEvent;
    Event *nextEvent;
    IBOutlet UILabel *nextEventLabel;
    IBOutlet UILabel *timeToNextEventLabel;

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
    //[self updateTime];
    
    // create a timer that updates the clock
    // NSLog (@"initiating the timer");
    
    
    
     // Set the web view as hidden initially so that you don't get the grey flash
     self.eventDisplayWebView.hidden = YES;
     
    [NSTimer scheduledTimerWithTimeInterval: 1.0
                                     target: self
                                   selector: @selector(updateTime)
                                   userInfo: nil
                                    repeats: NO];
    
    // repeat every # seconds - low for testing, up to 30 or so for release
    [NSTimer scheduledTimerWithTimeInterval: 5.0
                                     target: self
                                   selector: @selector(updateTime)
                                   userInfo: nil
                                    repeats: YES];
    
    
    // this should probably be a table tied to a fetched results controller instead of a webview tied to a timer
    // should I send it the managed object context or just the frc?
     
        
    // configure view is from the basic template
    //[self configureView];
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
    
    // NSLog(@"Update the time and check Now What?");
    
    NSDateFormatter *dayFormatter =[[NSDateFormatter alloc] init];
    
    NSDate *dateNow = [NSDate date];
    
    // get todays day with day formatter and compare to eventDate
    [dayFormatter setDateFormat:@"MMddYYYY"];
    
    NSString *todaysDate = [dayFormatter stringFromDate:[NSDate date]];
    
    // NSLog (@"Todays date is \'%@\' - compare to %@", todaysDate, rootView.eventDate);
    
    BOOL isToday;
    
    if ([todaysDate isEqualToString:self.viewDate]) {
        
        NSLog(@"it is set to today");
        
        isToday = TRUE;
        
        
    } else {
        
        NSLog(@"it is NOT set to today");
        // Only show the date
        
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
        
        NSLog (@"%f - %ld -%ld - %ld", timeToNextEvent, hours, secsLeftover, minutes);
        
        //countdownLabel.font = [UIFont fontWithName:@"Whiteboard Modern" size:20];
        //[text appendString:[NSString stringWithFormat:@"Countdown to next event: %ld hours and %ld minutes", hours, minutes]];
        [text appendString:[NSString stringWithFormat:@"Next event starts: "]];
        
        
        NSLog(@"Countdown to next event: %ld hours and %ld minutes", hours, minutes);
        
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
        
        
        
        nextEventLabel.text = nextEvent.eventText;
        timeToNextEventLabel.text = text;
        
    }
    
    
}



- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
    //// NSLog(@"*** WebView Finished loading");
    
    [self.eventDisplayWebView stringByEvaluatingJavaScriptFromString:
     [NSString stringWithFormat: @"document.body.scrollTop = %d", webViewOffset]];
    
    //// NSLog(@"%@", [NSString stringWithFormat: @"document.body.scrollTop = %d", webViewOffset]);
    
    self.eventDisplayWebView.hidden = NO;
    
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
    
    // what do I do here?? nothing if the segue things works
    
    //I could toggle the checkmak here
    
    
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsControllerDetail
{
    if (_fetchedResultsControllerDetail != nil) {
        return _fetchedResultsControllerDetail;
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
    NSPredicate *requestPredicate = [NSPredicate predicateWithFormat:@"(eventDate like %@) AND (schedule.scheduleName like %@)", [Event returnDateString:self.viewNSDate], self.viewSchedule.scheduleName];
    
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
    // if event 
    
    
    // this casts the cell to a EventCell
    EventCell *eventCell = (EventCell *)cell;
    
    // this gets the data from the fetched results
    Event *event = [self.fetchedResultsControllerDetail objectAtIndexPath:indexPath];
    
    // this sets the cell labels
    eventCell.eventTextLabel.text = event.eventText;
    
    eventCell.eventTimeLabel.text = [Event formatEventTime:event.eventNSDate] ;
    
    eventCell.eventNotesLabel.text = event.eventNotes;
    
    
}

- (void)updateDetailView {
    
    
    // update the viewDate variables, reload all the new data, and update the table
    
    self.fetchedResultsControllerDetail = nil;
    [self.detailTableView reloadData];
    
}




@end
