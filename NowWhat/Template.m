//
//  Template.m
//  NowWhat
//
//  Created by Rich Humphrey on 10/21/13.
//  Copyright (c) 2013 Rich Humphrey. All rights reserved.
//

#import "Template.h"
#import "TemplateEvent.h"


@implementation Template

@dynamic templateName;
@dynamic templateListOrder;
@dynamic events;



+ (BOOL) templateNameExists: (NSString *)templateNameField inMOC:(NSManagedObjectContext *)moc {
    
    // now check to see if there is already a template with that name
    // if so, should I let them overwrite it?
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [NSEntityDescription entityForName:@"Template" inManagedObjectContext:moc];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"templateName like %@", templateNameField];
    
    NSError *error = nil;
    if ([moc countForFetchRequest:fetchRequest error:&error] > 0) {
        
        //NSLog(@"this template exists");
        
        return TRUE;
        
        
    } else {
        
        return FALSE;
        
    }
    
}

+ (NSNumber *) getNextTemplateOrderInMOC:(NSManagedObjectContext *)moc {
    // now check to see if there is already a Template with that name
    // if so, should I let them overwrite it?
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [NSEntityDescription entityForName:@"Template" inManagedObjectContext:moc];
    [fetchRequest setIncludesPropertyValues:NO];
    [fetchRequest setIncludesSubentities:NO];
    
    
    NSError *error = nil;
    
    //NSNumber *count = [NSNumber numberWithInt:[moc countForFetchRequest:fetchRequest error:&error]];
    NSNumber *count = [NSNumber numberWithInt:(int)([moc countForFetchRequest:fetchRequest error:&error])];
    
    //NSLog(@"next template order is %@", count);
    
    return count;
    
}


+ (Template *) returnTemplateForName:(NSString * ) templateNameToGet inContext:(NSManagedObjectContext *)moc {
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Template" inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    
    // setup the predicate to return just the wanted date and Template
    NSPredicate *requestPredicate = [NSPredicate predicateWithFormat:@"templateName like %@", templateNameToGet];
    [fetchRequest setPredicate:requestPredicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [moc executeFetchRequest:fetchRequest error:&error];
    
    if (fetchedObjects.count == 0) {
        
        // then no Templates were found with this name
        return (nil);
        
    }
    
    // otherwise return the first one fetched
    return fetchedObjects[0];
    
}


@end
