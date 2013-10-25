//
//  SaveTemplateViewController.m
//  NowWhat
//
//  Created by Rich Humphrey on 10/21/13.
//  Copyright (c) 2013 Rich Humphrey. All rights reserved.
//

#import "SaveTemplateViewController.h"

@interface SaveTemplateViewController ()

@end

@implementation SaveTemplateViewController

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


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
 
    EventCell *eventCell = (EventCell *)cell;
    Event *event = [self.templateEvents objectAtIndex:indexPath.row];
    
    
    eventCell.eventTextLabel.text = event.eventText;
    
    eventCell.eventTimeLabel.text = [Event formatEventTime:event.eventNSDate];
    
    eventCell.eventNotesLabel.text = event.eventNotes;
    
    NSLog(@"text is %@", event.eventText);
    
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.templateEvents count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SaveTemplateCell"];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
    
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // Delete the row from the data source
        [[self templateEvents] removeObjectAtIndex:[indexPath row]];
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // this is usually in the prepare for segue, but since it's not a nav controller, I don't think that works
    
            
    // Send the EditTemplateEventViewController the appropriate event that needs editing
    //NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    //NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    Event *event = [self.templateEvents objectAtIndex:indexPath.row];
    //TemplateEvent *templateEvent;
    
//    UINavigationController *navigationController = segue.destinationViewController;
//    EditTemplateEventViewController *controller = (EditTemplateEventViewController *)navigationController.topViewController;
//    controller.managedObjectContext = self.managedObjectContext;
//    controller.templateEventToEdit = templateEvent;
    //controller.delegate = self;
    NSLog(@"the event selected is %@", event.eventText);
            
            
}


- (IBAction)cancel
{
    [[self navigationController] popViewControllerAnimated:YES];

}
- (IBAction)save

    {
    if ([templateNameField.text isEqualToString:@""]) {
        
        // NSLog(@"Text field is empty");
        
        UIAlertView *emptyTextAlert;
        
        emptyTextAlert = [[UIAlertView alloc]
                          initWithTitle:@"Please enter a template name"
                          message:@""
                          delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
        
        [emptyTextAlert show];
        
        return;
        
    }

    // Add these events to the template database
    // do error checking and save to managedObjectContext
    Template *template = nil;
    //TemplateEvent *templateEvent = nil;
        
    template = [NSEntityDescription insertNewObjectForEntityForName:@"Template" inManagedObjectContext:self.managedObjectContext];
        
    template.templateName = templateNameField.text;
        
    // Now go through all the events in the list and add them to the TemplateEvents entity
        
    for (Event *event in self.templateEvents) {
        
        TemplateEvent *templateEvent;
        templateEvent = [NSEntityDescription insertNewObjectForEntityForName:@"TemplateEvent" inManagedObjectContext:self.managedObjectContext];
        
        templateEvent.eventText = event.eventText;
        templateEvent.eventNotes = event.eventNotes;
        templateEvent.template = template;
        
        // strip the date off of eventNSDate and just save the time
        templateEvent.eventTime = event.eventNSDate;
        
        
            
    }
        
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Error: %@", error);
        abort();
    }
        
        
        
        
        
        
    [[self navigationController] popViewControllerAnimated:YES];

}



@end
