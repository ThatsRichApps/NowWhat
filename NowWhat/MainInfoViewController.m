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
    
    NSMutableString *htmlString = [[NSMutableString alloc] init];
    
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    
    
    
    if ([self.callingView isEqualToString:@"InfoSchedules"]) {
        
        [htmlString appendString:@"<h2 align=\"center\">Now What?</h2>"];
        
        [htmlString appendString:@"<p>Welcome to the newest version of the \"Now What\" application!  This version contains several new features:  Multiple schedules can now be viewed on the same device.  Create a new schedule by clicking the + button at the top right.  Events created in each schedule are unique to the schedule.  Templates are shared between all schedules.</p>"];
        
        [htmlString appendString:@"<p>After creating and selecting a schedule, use the following icons to manage your events:</p>"];
        
        [htmlString appendString:@"<p><img src=\"line__0000s_0090_calendar.png\" alt=\"calendar\" width=\"24\" height=\"24\" /> - Change the day that you are currently viewing.  This allows you to setup events for future dates.</p>"];
        [htmlString appendString:@"<p><img src=\"line__0000s_0103_folder.png\" alt=\"save\" width=\"24\" height=\"21\" /> - Save the currently loaded day as a Template.</p>"];
        [htmlString appendString:@"<p><img src=\"line__0000s_0102_box.png\" width=\"24\" height=\"23\" /> - Load a previously saved Template into the currently displayed day.</p>"];
        [htmlString appendString:@"<p><img src=\"line__0000s_0103_share.png\" width=\"24\" height=\"28\" /> - Share (Mail or Print) the currently loaded events.  Events can be mailed to other Now What users and their schedules will be updated.</p>"];
        [htmlString appendString:@"<p><img src=\"line__0000s_0082_lock.png\" width=\"20\" height=\"26\" /> - Lock the app so that none of the settings can be changed.  This disables all the buttons.</p>"];
        
        [htmlString appendString:@"<p>Settings Additions:  In the Settings app for your device, listed under \"NowWhat\", you can change the default app settings.  These include:<br>"];
        
        [htmlString appendString:@"Notifications:  The app will notify you of coming events, you can set it to none, 1 minute before, or 5 minutes before the event.<br>"];
        [htmlString appendString:@"Lock Reset:  If you lock your app and forget the password, this setting will open it up again.<br>"];
        [htmlString appendString:@"24 Hour Time:  This setting switches all times to be in 24 hour time rather than AM/PM.<br>"];
        [htmlString appendString:@"Use End Times:  Adds the use of end times for all your events everywhere within the app<br></p>"];

    }
    
    if ([self.callingView isEqualToString:@"InfoSaveTemplates"]) {
        
        [htmlString appendString:@"From this view, you can save a list of events as a template.  To add new events to this template, click the add button (+).  New events will show up in the template, but not be changed in your daily event list.  Events can be edited by clicking on them."];
    
        
        
        
    }

    if ([self.callingView isEqualToString:@"InfoListTemplates"]) {
        
        [htmlString appendString:@"On this screen, you can see a list of templates.  If none are setup, you can create one by clicking on the add buttons (+), or by clicking the \"Save\" button on the daily events page.  Templates can now be edited or modified by clicking on the template and editing it.  To load a template into the currently active day, click on the template in the list, then click the \"Load\" button on the next page."];
        
        
    
    }

    
    
    [infoWebView loadHTMLString:htmlString baseURL:baseURL];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
