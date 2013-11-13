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
        NSString *textFileContentsString = @"some data, some more data, yet more data";
        
        NSData *textFileContentsData = [textFileContentsString dataUsingEncoding:NSASCIIStringEncoding];
        
        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
        [picker setSubject:@"Now What Schedule"];
        
        //[picker addAttachmentData:bugData mimeType:@"application/scarybugs" fileName:[_bugDoc getExportFileName]];
        [picker addAttachmentData:textFileContentsData mimeType:@"application/nowwhat" fileName:@"data.nwf"];

        
        [picker setToRecipients:[NSArray array]];
        [picker setMessageBody:@"Here is my schedule for today.  You can tap the file below to open in your copy of \"Now What\".  Don't have Now What? - get it in the app store!" isHTML:NO];
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
