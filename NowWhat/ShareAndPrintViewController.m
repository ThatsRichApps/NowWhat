//
//  ShareAndPrintViewController.m
//  NowWhat
//
//  Created by Rich Humphrey on 11/3/13.
//  Copyright (c) 2013 Rich Humphrey. All rights reserved.
//

#import "ShareAndPrintViewController.h"

@interface ShareAndPrintViewController ()

@end

@implementation ShareAndPrintViewController

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancel
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)mailData {
    
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
            fields[@"eventDate"] = [Event JSONEventTime:thisEvent.eventNSDate];
            //[fields setObject:[Event JSONEventTime:thisEvent.eventEndNSDate] forKey:@"eventEndDate"];
            fields[@"scheduleName"] = self.viewSchedule.scheduleName;

            [eventsArray addObject:fields];
            
        }
        
        NSError *JSONerror;
        NSData *JSONData = [NSJSONSerialization dataWithJSONObject:eventsArray options:kNilOptions error:&JSONerror];
        
        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
        [picker setSubject:@"Now What Schedule"];
        
        //[picker addAttachmentData:bugData mimeType:@"application/scarybugs" fileName:[_bugDoc getExportFileName]];
        [picker addAttachmentData:JSONData mimeType:@"application/nowwhat" fileName:@"data.nwf"];

        
        [picker setToRecipients:@[]];
        [picker setMessageBody:@"Here is my schedule for today.  You can tap the file below to open in your copy of \"Now What\".<br>Don't have Now What? - get it in the app store! <a href=\"https://itunes.apple.com/us/app/now-what/id434244026?mt=8&uo=4\" target=\"itunes_store\">Now What Schedule</a>" isHTML:YES];
        
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
@end
