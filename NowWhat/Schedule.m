//
//  Schedule.m
//  NowWhat
//
//  Created by Rich Humphrey on 11/1/13.
//  Copyright (c) 2013 Rich Humphrey. All rights reserved.
//

#import "Schedule.h"
#import "Event.h"


@implementation Schedule

@dynamic scheduleName;
@dynamic scheduleListOrder;
@dynamic event;






+ (Schedule *) returnScheduleForName:(NSString * ) scheduleNameToGet inContext:(NSManagedObjectContext *)moc {
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Schedule" inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    
    // setup the predicate to return just the wanted date and schedule
    NSPredicate *requestPredicate = [NSPredicate predicateWithFormat:@"scheduleName like %@", scheduleNameToGet];
    [fetchRequest setPredicate:requestPredicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [moc executeFetchRequest:fetchRequest error:&error];
    
    if (fetchedObjects.count == 0) {

        // then no schedules were found with this name
        return (nil);
    
    }
    
    // otherwise return the first one fetched
    return fetchedObjects[0];
    
}

+ (BOOL) scheduleNameExists: (NSString *)scheduleNameField inMOC:(NSManagedObjectContext *)moc {
    
    // now check to see if there is already a schedule with that name
    // if so, should I let them overwrite it?
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [NSEntityDescription entityForName:@"Schedule" inManagedObjectContext:moc];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"scheduleName like %@", scheduleNameField];
    [fetchRequest setIncludesPropertyValues:NO];
    [fetchRequest setIncludesSubentities:NO];
    
    NSError *error = nil;
    if ([moc countForFetchRequest:fetchRequest error:&error] > 0) {
        
        NSLog(@"this schedule exists");
        
        return TRUE;
        
        
    } else {
        
        return FALSE;
        
    }
    
}

+ (NSNumber *) getNextScheduleOrderInMOC:(NSManagedObjectContext *)moc {
    // now check to see if there is already a schedule with that name
    // if so, should I let them overwrite it?
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [NSEntityDescription entityForName:@"Schedule" inManagedObjectContext:moc];
    [fetchRequest setIncludesPropertyValues:NO];
    [fetchRequest setIncludesSubentities:NO];

    
    NSError *error = nil;
    
    NSNumber *count = [NSNumber numberWithInt:[moc countForFetchRequest:fetchRequest error:&error]];
    
    NSLog(@"next schedule order is %@", count);
    
    return count;
    
}




@end
