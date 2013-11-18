//
//  ShareAndPrintViewController.h
//  NowWhat
//
//  Created by Rich Humphrey on 11/3/13.
//  Copyright (c) 2013 Rich Humphrey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "Schedule.h"
#import "Event.h"
#import "UnmanagedEvent.h"


@interface ShareAndPrintViewController : UIViewController <MFMailComposeViewControllerDelegate> {
    
    
}

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSDate *viewNSDate;
@property (nonatomic, retain) Schedule *viewSchedule;


- (IBAction)cancel;
- (IBAction)mailData;



@end
