//
//  AddScheduleViewController.m
//  NowWhat
//
//  Created by Rich Humphrey on 11/1/13.
//  Copyright (c) 2013 Rich Humphrey. All rights reserved.
//

#import "AddScheduleViewController.h"

@interface AddScheduleViewController ()

@end

@implementation AddScheduleViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [scheduleField becomeFirstResponder];
    

    // dismiss keyboard on tap outside of field
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(save)];
    
    [self.view addGestureRecognizer:tap];

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

- (IBAction)save
{
    
    // return an error if the field is empty
    if ([scheduleField.text isEqualToString:@""]) {
        
        // NSLog(@"Text field is empty");
        
        UIAlertView *emptyTextAlert;
        
        emptyTextAlert = [[UIAlertView alloc]
                          initWithTitle:@"Please enter a schedule name"
                          message:@""
                          delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
        
        [emptyTextAlert show];
        
        return;
        
    }
    
    // now check to see if there is already a schedule with that name
    // if so, should I let them overwrite it?
    
    if ([Schedule scheduleNameExists:scheduleField.text inMOC:self.managedObjectContext]) {
        
        NSLog(@"this schedule exists");
        
        
        UIAlertView *emptyTextAlert;
        
        emptyTextAlert = [[UIAlertView alloc]
                          initWithTitle:@"A schedule with this name already exists"
                          message:@""
                          delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
        
        [emptyTextAlert show];
        
        return;
        
        
    }
    
    // have it's delegate (MainScheduleViewController) add a new field
    [self.delegate addScheduleWithName:scheduleField.text];
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)dismissKeyboard {
    
    // this finds the current responder and resigns it
    [self.view endEditing:YES];
 
}



@end
