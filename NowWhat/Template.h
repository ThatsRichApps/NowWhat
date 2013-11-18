//
//  Template.h
//  NowWhat
//
//  Created by Rich Humphrey on 10/21/13.
//  Copyright (c) 2013 Rich Humphrey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TemplateEvent;

@interface Template : NSManagedObject

@property (nonatomic, retain) NSString * templateName;
@property (nonatomic, retain) NSNumber * templateListOrder;
@property (nonatomic, retain) NSSet *events;
@end

@interface Template (CoreDataGeneratedAccessors)

- (void)addEventsObject:(TemplateEvent *)value;
- (void)removeEventsObject:(TemplateEvent *)value;
- (void)addEvents:(NSSet *)values;
- (void)removeEvents:(NSSet *)values;

+ (BOOL) templateNameExists: (NSString *)templateNameField inMOC:(NSManagedObjectContext *)moc;
+ (NSNumber *) getNextTemplateOrderInMOC:(NSManagedObjectContext *)moc;
+ (Template *) returnTemplateForName:(NSString * ) templateName inContext:(NSManagedObjectContext *)moc;
@end
