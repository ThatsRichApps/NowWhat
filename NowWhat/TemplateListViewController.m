//
//  TemplateListViewController.m
//  NowWhat
//
//  Created by Rich Humphrey on 10/20/13.
//  Copyright (c) 2013 Rich Humphrey. All rights reserved.
//

#import "TemplateListViewController.h"

@interface TemplateListViewController ()

@end

@implementation TemplateListViewController

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
 
    // add edit / done button on the right top
    self.navigationItem.rightBarButtonItem = self.editButtonItem;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
- (void)insertNewObject:(id)sender
{
    NSManagedObjectContext *context = [self.fetchedResultsControllerTemplates managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsControllerTemplates fetchRequest] entity];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    // If appropriate, configure the new managed object.
    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
    [newManagedObject setValue:[NSDate date] forKey:@"timeStamp"];
    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}
*/

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsControllerTemplates sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsControllerTemplates sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TemplateCell"];
    
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSManagedObjectContext *context = [self.fetchedResultsControllerTemplates managedObjectContext];
        [context deleteObject:[self.fetchedResultsControllerTemplates objectAtIndexPath:indexPath]];
        
        NSError *error = nil;
        if (![context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
        NSMutableArray *tempList = [[self.fetchedResultsControllerTemplates fetchedObjects] mutableCopy];
        
        for (int i=0; i < [tempList count]; i++) {
            [(Event *)tempList[i] setValue:@(i) forKey:@"templateListOrder"];
        }
        
        if (![context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
            
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // this table should support reordering
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    // this is handled elsewhere through a segue
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
 
    if ([[segue identifier] isEqualToString:@"ShowTemplate"]) {
        
        // get the template that was selected and send it to showtemplateview
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        Template *template = [self.fetchedResultsControllerTemplates objectAtIndexPath:indexPath];

        ShowTemplateViewController *controller = (ShowTemplateViewController *)[segue destinationViewController];
        controller.managedObjectContext = self.managedObjectContext;
        controller.templateToShow = template;

        // pass in the current viewDate and schedule for when a template is loaded
        controller.viewNSDate = self.viewNSDate;
        controller.viewSchedule = self.viewSchedule;
        
    }

    if ([[segue identifier] isEqualToString:@"InfoListTemplates"]) {
        
        UINavigationController *navigationController = segue.destinationViewController;
        MainInfoViewController *controller = (MainInfoViewController *)navigationController;
        controller.callingView = @"InfoListTemplates";
        
    }
    
    if ([[segue identifier] isEqualToString:@"AddTemplate"]) {
        
        SaveTemplateViewController *controller = (SaveTemplateViewController *)[segue destinationViewController];
        // send the data to the save template in the form of an array
        controller.templateEvents = nil;
        controller.managedObjectContext = self.managedObjectContext;
        
    }

}



- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    changeIsUserDriven = YES;
    
    NSMutableArray *tempList = [[self.fetchedResultsControllerTemplates fetchedObjects] mutableCopy];
    Event *objectToMove = tempList[fromIndexPath.row];
    
    [tempList removeObjectAtIndex:fromIndexPath.row];
    [tempList insertObject:objectToMove atIndex:toIndexPath.row];
    
    for (int i=0; i < [tempList count]; i++) {
        [(Event *)tempList[i] setValue:@(i) forKey:@"templateListOrder"];
    }
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Error: %@", error);
        abort();
    }
    
    changeIsUserDriven = NO;
    
}




#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsControllerTemplates
{
    if (_fetchedResultsControllerTemplates != nil) {
        return _fetchedResultsControllerTemplates;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Template" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"templateListOrder" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *afetchedResultsControllerTemplates = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Templates"];
    afetchedResultsControllerTemplates.delegate = self;
    self.fetchedResultsControllerTemplates = afetchedResultsControllerTemplates;
    
	NSError *error = nil;
	if (![self.fetchedResultsControllerTemplates performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsControllerTemplates;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    if (changeIsUserDriven) return;
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    if (changeIsUserDriven) return;
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    if (changeIsUserDriven) return;

    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if (changeIsUserDriven) return;

    [self.tableView endUpdates];
}

/*
 // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
 {
 // In the simplest, most efficient, case, reload the table view.
 [self.tableView reloadData];
 }
 */

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    
    // this casts the cell to a TemplateCell
    TemplateCell *templateCell = (TemplateCell *)cell;
    
    // this gets the data from the fetched results
    Template *template = [self.fetchedResultsControllerTemplates objectAtIndexPath:indexPath];
    
    // this sets the cell label to the templateName
    templateCell.templateNameLabel.text = template.templateName;
    
}


@end
