//
//  Schedule.h
//  NowWhat
//
//  Created by Rich Humphrey on 11/1/13.
//  Copyright (c) 2013 Rich Humphrey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event;
@class Schedule;

@interface Schedule : NSManagedObject

@property (nonatomic, retain) NSString * scheduleName;
@property (nonatomic, retain) NSSet *event;
@end

@interface Schedule (CoreDataGeneratedAccessors)

- (void)addEventObject:(Event *)value;
- (void)removeEventObject:(Event *)value;
- (void)addEvent:(NSSet *)values;
- (void)removeEvent:(NSSet *)values;


+ (Schedule *) returnScheduleForName:(NSString * ) scheduleName inContext:(NSManagedObjectContext *)moc;
+ (BOOL) scheduleNameExists: (NSString *)scheduleNameField inMOC:(NSManagedObjectContext *)moc;


@end
