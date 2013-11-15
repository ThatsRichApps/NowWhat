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
        
        NSLog(@"this template exists");
        
        return TRUE;
        
        
    } else {
        
        return FALSE;
        
    }
    
}




@end
