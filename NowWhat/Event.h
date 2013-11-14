//
//  Event.h
//  NowWhat
//
//  Created by Rich Humphrey on 10/16/13.
//  Copyright (c) 2013 Rich Humphrey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Event : NSManagedObject

@property (nonatomic, retain) NSString * eventNotes;
@property (nonatomic, retain) NSString * eventText;
@property (nonatomic, retain) NSDate * eventNSDate;
@property (nonatomic, retain) NSDate * eventEndNSDate;
@property (nonatomic, retain) NSString * eventDate;
@property (nonatomic, assign) BOOL eventChecked;
@property (nonatomic, retain) NSManagedObject * schedule;

+ (NSString *)formatEventTime: (NSDate *)dateTime;
+ (NSString *)returnDateString: (NSDate *)dateTime;
+ (NSDate *)mergeDate: (NSString *)dateString withTime:(NSDate *)timeOfDay;
+ (NSDate *)normalizeDay: (NSDate *)dateTime;
+ (NSDate *)resetToBaseTime: (NSDate *)dateTime;

- (void)toggleChecked;

@end
