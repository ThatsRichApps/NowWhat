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
        
        infoTextView.text = @"this was called from the schedule page";
        
    }
    
    if ([self.callingView isEqualToString:@"InfoSaveTemplates"]) {
        
        infoTextView.text = @"this was called from the save templates page";
        
    }

    if ([self.callingView isEqualToString:@"InfoListTemplates"]) {
        
        infoTextView.text = @"this was called from the list templates page";
        
    }

    
    
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
