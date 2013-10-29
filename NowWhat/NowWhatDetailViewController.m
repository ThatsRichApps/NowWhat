//
//  NowWhatDetailViewController.m
//  NowWhat
//
//  Created by Rich Humphrey on 10/14/13.
//  Copyright (c) 2013 Rich Humphrey. All rights reserved.
//

#import "NowWhatDetailViewController.h"

@interface NowWhatDetailViewController ()
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
    
    // Set the web view as hidden initially so that you don't get the grey flash
    self.eventDisplayWebView.hidden = YES;
    
    // Start the time and now what check, then set to recheck every 30 secs
    //[self updateTime];
    
    // create a timer that updates the clock
    // NSLog (@"initiating the timer");
    
    [NSTimer scheduledTimerWithTimeInterval: 1.0
                                     target: self
                                   selector: @selector(updateTime)
                                   userInfo: nil
                                    repeats: NO];
    
    // repeat every # seconds - low for testing, up to 30 or so for release
    [NSTimer scheduledTimerWithTimeInterval: 3.0
                                     target: self
                                   selector: @selector(updateTime)
                                   userInfo: nil
                                    repeats: YES];
    

    
    
    
    
    
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
    
    
    //int webViewOffset =  [[eventDisplayWebView stringByEvaluatingJavaScriptFromString: @"scrollY"] intValue];
    webViewOffset =  [[self.eventDisplayWebView stringByEvaluatingJavaScriptFromString: @"window.pageYOffset"] intValue];
    
    //// NSLog (@"** webviewoffset = %d", webViewOffset);
    
    // Create a NSMutableString with the data that will be printed to the text view
    NSMutableString *html = [NSMutableString new];
    
    NSDateFormatter *formatter =[[NSDateFormatter alloc] init];
    NSDateFormatter *dayFormatter =[[NSDateFormatter alloc] init];
    
    NSDate *dateNow = [NSDate date];
    
    // This will produce a time that looks like "12:15:00 PM".
    //[formatter setTimeStyle:NSDateFormatterMediumStyle];
    
    
    // Start the html code for the uiwebview
    [html appendString:@"<html><head><style>body{background-color:transparent;}</style></head><body><font size=\"5\" face=\"Chalkboard SE\">"];
    
    
    // get todays day with day formatter and compare to eventDate
    [dayFormatter setDateFormat:@"MMddYYYY"];
    
    NSString *todaysDate = [dayFormatter stringFromDate:[NSDate date]];
    
    // NSLog (@"Todays date is \'%@\' - compare to %@", todaysDate, rootView.eventDate);
    
    BOOL isToday;
    
    if ([todaysDate isEqualToString:self.viewDate]) {
        
        //// NSLog(@"it is set to today");
        
        // Show the time of day as well as the date
        [formatter setDateFormat:@"EEEE, MM/dd, hh:mm a"];
        [html appendString:[formatter stringFromDate:dateNow]];
        
        isToday = TRUE;
        
        
    } else {
        
        //// NSLog(@"it is NOT set to today");
        // Only show the date
        [formatter setDateFormat:@"EEEE, MM/dd"];
        
        [html appendString:@"Schedule for:<br>"];
        
        [html appendString:[formatter stringFromDate:self.viewNSDate]];
        [html appendString:@"<br><font size = \"2\">(Change day to today for current events)</font>"];
        
        isToday = FALSE;
        
        
    }
    
    [html appendString:@"<br>"];
    
    self.eventDisplayWebView.opaque = NO;
    self.eventDisplayWebView.backgroundColor = [UIColor clearColor];
    
    // Turns off the bounce feature
    for (id subview in self.eventDisplayWebView.subviews)
        if ([[subview class] isSubclassOfClass: [UIScrollView class]])
            ((UIScrollView *)subview).bounces = NO;
    //*/
    
    //[eventDisplayTextView setText:[formatter stringFromDate:dateNow]];
    
    // now go through the rootView.dayData array to determine what is now and what is next
    
    UnmanagedEvent *lastEvent = nil;
    UnmanagedEvent *nextEvent = nil;
    
    //float timeFromLastEvent;
    float timeToNextEvent;
    
    // Go through the dayData events one at a time to see which one was last and next
    for (UnmanagedEvent *event in self.dayData) {
        
        // Create an NSDate variable that can be compared to dateNow
        //// NSLog (@"check current time against %@", event.eventTime);
        //// NSLog (@"current time is %@", dateNow);
        //// NSLog (@"event date is %@", event.eventNSDate);
        
        // NSDate init with string needs the format: YYYY-MM-DD HH:MM:SS ±HHMM
        NSDateFormatter *eventDayFormat =[[NSDateFormatter alloc] init];
        [eventDayFormat setDateFormat:@"yyyy-MM-dd"];
        NSString *eventDay = [eventDayFormat stringFromDate:event.eventTime];
        
        //// NSLog (@"event day is %@", eventDay);
        
        NSDateFormatter *eventDateFormat =[[NSDateFormatter alloc] init];
        
        [eventDateFormat setDateFormat:@"yyyy-MM-dd HH:mm"];
        
        NSString *thisEventString = [NSString stringWithFormat:@"%@ %@", eventDay, [Event formatEventTime:event.eventTime]];
        
        // NSLog (@"Formatted event Date is %@", thisEventString);
        
        NSDate *thisEventDate = [eventDateFormat dateFromString: thisEventString];
        
        //// NSLog (@"Compare Date is %@", thisEventDate);
        
        // if eventTime is before
        
        switch ([dateNow compare:thisEventDate]) {
                
            case NSOrderedSame:
                
                lastEvent = event;
                //timeFromLastEvent = (long) [dateNow timeIntervalSinceDate:thisEventDate];
                break;
                
            case NSOrderedDescending:
                
                lastEvent = event;
                //timeFromLastEvent = (long) [dateNow timeIntervalSinceDate:thisEventDate];
                break;
                
            case NSOrderedAscending:
                
                nextEvent = event;
                timeToNextEvent = (long) [thisEventDate timeIntervalSinceDate:dateNow];
                break;
                
        }
        
        if (nextEvent != nil) {
            break;
        }
        
        
    }
    
    if ((nextEvent != nil)&&(isToday)) {
        
        long hours = (long) timeToNextEvent / 3600;
        long secsLeftover = (long) timeToNextEvent % 3600;
        long minutes = (long) secsLeftover / 60;
        
        // round minutes up
        minutes = minutes + 1;
        
        // NSLog (@"%f - %ld -%ld - %ld", timeToNextEvent, hours, secsLeftover, minutes);
        
        //countdownLabel.font = [UIFont fontWithName:@"Whiteboard Modern" size:20];
        //countdownLabel.text = [NSString stringWithFormat:@"Countdown to next event: %ld hours and %ld minutes", hours, minutes];
        
        [html appendString:@"Next Event In: <font color = \"red\" size=\"4\">"];
        
        if (hours != 0) {
            
            [html appendString:[NSString stringWithFormat:@"%ld hour", hours]];
            
            if (hours == 1) {
                
                [html appendString:@" and "];
                
            } else {
                
                [html appendString:@"s and "];
                
                
                
            }
            
        }
        
        [html appendString:[NSString stringWithFormat:@"%ld minutes</font><br>", minutes]];
        
        
    }
    
    
    // Go through event class again to print it to the display
    for (UnmanagedEvent *eventItem in self.dayData) {
        
        // I have the NSString eventTime = "19:00".  Need to split out and convert from 24 hour notation to AMPM
        // I now use the method formatEventTime of Event class
        
        [html appendString:[Event formatEventTime:eventItem.eventTime]];
        [html appendString:@" - "];
        [html appendString:eventItem.eventText];
        
        if ((eventItem == lastEvent) && isToday) {
            
            [html appendString:@"</font>"];
            
        } else if ((eventItem == nextEvent) && isToday) {
            
            [html appendString:@"</font>"];
            
        }
        
        
        if (![eventItem.eventNotes isEqualToString:@""]) {
            
            [html appendString:@"<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"];
            
            NSString *formattedString = eventItem.eventNotes;
            formattedString = [formattedString stringByReplacingOccurrencesOfString:@"\n"
                                                                         withString:@"<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"];
            [html appendString:formattedString];
            
        }
        
        [html appendString:@"<br>"];
        
        
    }
    
    // Finish the html statement and display
    
    [html appendString: @"</body></html>"];
    
    //// NSLog(@"String to load: %@", html);
    
    
    self.eventDisplayWebView.hidden = YES;
    
    [self.eventDisplayWebView loadHTMLString:html baseURL:[NSURL URLWithString:@""]];
    
}



- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
    //// NSLog(@"*** WebView Finished loading");
    
    [self.eventDisplayWebView stringByEvaluatingJavaScriptFromString:
     [NSString stringWithFormat: @"document.body.scrollTop = %d", webViewOffset]];
    
    //// NSLog(@"%@", [NSString stringWithFormat: @"document.body.scrollTop = %d", webViewOffset]);
    
    self.eventDisplayWebView.hidden = NO;
    
}




@end
