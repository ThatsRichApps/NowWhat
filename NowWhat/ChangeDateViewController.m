//
//  ChangeDateViewController.m
//  NowWhat
//
//  Created by Rich Humphrey on 10/20/13.
//  Copyright (c) 2013 Rich Humphrey. All rights reserved.
//

#import "ChangeDateViewController.h"

@interface ChangeDateViewController ()

@end

@implementation ChangeDateViewController {
    
    
    
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
	// Do any additional setup after loading the view.

    if (self.selectedDate != nil) {
        
        [eventDatePicker setDate:self.selectedDate animated:YES];
        
    } else {
        
        [eventDatePicker setDate:[NSDate date] animated:YES];

    }
    
    [self changeDayOfTheWeek];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(IBAction) changeDayOfTheWeek {
    
    // change the day of the week label
    
    NSDateFormatter *formatter;
    NSString        *dayString;
    
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEEE"];
    
    dayString = [formatter stringFromDate:eventDatePicker.date];
    
    dayOfTheWeek.text = dayString;

}

-(IBAction) resetDatePicker {
    
    // Set date picker back to today
    
    [eventDatePicker setDate:[NSDate date] animated:YES];
    NSDateFormatter *formatter;
    NSString        *dayString;
    
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEEE"];
    
    dayString = [formatter stringFromDate:eventDatePicker.date];
    
    dayOfTheWeek.text = dayString;
    
}


- (IBAction)cancel
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)save
{
    
    self.selectedDate = eventDatePicker.date;
    
    [self.delegate changeDatePicker:self didChangeDate:self.selectedDate];
    
    //NSLog(@"the new date is %@", self.selectedDate);

    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];

}

// this is deprecated in ios 6, but still needed in 5
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}


@end
