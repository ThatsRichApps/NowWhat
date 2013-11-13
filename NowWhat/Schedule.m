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
@dynamic event;






+ (Schedule *) returnScheduleForName:(NSString * ) scheduleNameToGet inContext:(NSManagedObjectContext *)moc {
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Schedule" inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    
    // setup the predicate to return just the wanted date and schedule
    NSPredicate *requestPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"scheduleName like '%@'", scheduleNameToGet]];
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






@end
