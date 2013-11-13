//
//  MainInfoViewController.m
//  NowWhat
//
//  Created by Rich Humphrey on 11/3/13.
//  Copyright (c) 2013 Rich Humphrey. All rights reserved.
//

#import "MainInfoViewController.h"

@interface MainInfoViewController ()

@end

@implementation MainInfoViewController

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
    
    if ([self.callingView isEqualToString:@"InfoSchedules"]) {
        
        infoTextView.text = @"Welcome to the newest version of the \"Now What\" application!  This version contains several new features.  Multiple schedules can now be viewed on the same device.  Create a new schedule by clicking the + button at the top right.  Events created in each schedule are unique to the schedule.  Templates are shared between all schedules.";
        
    }
    
    if ([self.callingView isEqualToString:@"InfoSaveTemplates"]) {
        
        infoTextView.text = @"From this view, you can save a list of events as a template.  To add new events to this template, click the add button (+).  New events will show up in the template, but not be changed in your daily event list.  Events can be edited by clicking on them.";
        
    }

    if ([self.callingView isEqualToString:@"InfoListTemplates"]) {
        
        infoTextView.text = @"On this screen, you can see a list of templates.  If none are setup, you can create one by clicking on the add buttons (+), or by clicking the \"Save\" button on the daily events page.  Templates can now be edited or modified by clicking on the template and editing it.  To load a template into the currently active day, click on the template in the list, then click the \"Load\" button on the next page.";
        
    }

    
    
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
