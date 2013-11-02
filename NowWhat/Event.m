//
//  Event.m
//  NowWhat
//
//  Created by Rich Humphrey on 10/16/13.
//  Copyright (c) 2013 Rich Humphrey. All rights reserved.
//

#import "Event.h"


@implementation Event

@dynamic eventNotes;
@dynamic eventText;
@dynamic eventNSDate;
@dynamic eventDate;
@dynamic eventChecked;
@dynamic schedule;


- (void)toggleChecked    {
    self.eventChecked = !self.eventChecked;
}


+ (NSString *)formatEventTime: (NSDate *)dateTime {
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //[formatter setDateFormat:@"yyyy"];
    [formatter setDateFormat:@"hh:mm a"];
    
    //Optionally for time zone converstions
    //[formatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
    
    NSString *timeFormatted = [formatter stringFromDate:dateTime];
    
    return (timeFormatted);
    
    
}

+ (NSString *)returnDateString: (NSDate *)dateTime {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //[formatter setDateFormat:@"yyyy"];
    [formatter setDateFormat:@"MMddYYYY"];
    
    //Optionally for time zone converstions
    //[formatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
    
    NSString *dateFormatted = [formatter stringFromDate:dateTime];
    
    return (dateFormatted);
    
    
}

+ (NSDate *)mergeDate: (NSString *)dateString withTime:(NSDate *)timeOfDay {
    
    NSDate *mergedDate;
    
    // dateString is in the form MMddYYYY, and timeOfDay is an NSDate
    // we want to populate merged date with the dateString date at the timeOfDay time
    // now set the viewNSDate time to 8:00 am
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    
    // get the month day and year from the dateString
    NSString *monthStr = [dateString substringToIndex:2];
    NSString *dayStr   = [dateString substringWithRange:NSMakeRange(2, 2)];
    NSString *yearStr  = [dateString substringFromIndex:4];
    
    [components setDay:[dayStr intValue]];
    [components setMonth:[monthStr intValue]];
    [components setYear:[yearStr intValue]];
    
    // get the hour and minute from the timeOfDay
    // first format a string with time, then parse out the hour and minute
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"kk:mm"];
    NSString *timeFormatted = [formatter stringFromDate:timeOfDay];

    NSArray *stringComponents = [timeFormatted componentsSeparatedByString:@":"];
    NSString *hour = [stringComponents objectAtIndex:0];
    NSString *minute = [[stringComponents objectAtIndex:1] substringToIndex:2];
    
    [components setHour:[hour intValue]];
    [components setMinute:[minute intValue]];
    
    mergedDate = [gregorian dateFromComponents:components];
    //NSLog(@"merged dateTime is %@", mergedDate);
    
    return (mergedDate);
    
}

@end
