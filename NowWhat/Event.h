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
@property (nonatomic, retain) NSString * eventDate;
@property (nonatomic, retain) NSString * eventChecked;
@property (nonatomic, retain) NSString * eventSchedule;

- (NSString *)formattedTime;
+ (NSString *)formatEventTime: (NSDate *)dateTime;
+ (NSString *)returnDate: (NSDate *)dateTime;

@end
