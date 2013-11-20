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
@dynamic eventEndNSDate;
@dynamic eventDate;
@dynamic eventChecked;
@dynamic schedule;


- (void)toggleChecked    {
    self.eventChecked = !self.eventChecked;
}


+ (NSString *)formatEventTime: (NSDate *)dateTime {
    
    // Check the default time display preference
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setAMSymbol:@"am"];
    [formatter setPMSymbol:@"pm"];
 
    if ([preferences boolForKey:@"hour24"]) {
        [formatter setDateFormat:@"kk:mm"];
    } else {
        [formatter setDateFormat:@"hh:mma"];
    }

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
    NSString *hour = stringComponents[0];
    NSString *minute = [stringComponents[1] substringToIndex:2];
    
    [components setHour:[hour intValue]];
    [components setMinute:[minute intValue]];
    
    mergedDate = [gregorian dateFromComponents:components];
    //NSLog(@"merged dateTime is %@", mergedDate);
    
    return (mergedDate);
    
}


+ (NSDate *)normalizeDay: (NSDate *)dateTime {
    
    
    // take the given dateTime and reset it to day 0/0/0 for saving as a template Event
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"kk:mm"];
    
    //Optionally for time zone converstions
    //[formatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
    
    NSString *timeString = [formatter stringFromDate:dateTime];
    
    NSLog(@"The time to normallize is %@", timeString);
    
    // now set the viewNSDate time to 8:00 am
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    
    
    NSString *hourStr = [timeString substringToIndex:2];
    NSString *minStr = [timeString substringFromIndex:3];
    
    
    [components setDay:0];
    [components setMonth:0];
    [components setYear:0];
    [components setHour:[hourStr intValue]];
    [components setMinute:[minStr intValue]];
    
    NSDate *timeFormatted = [gregorian dateFromComponents:components];
    //NSLog(@"base time is %@", timeFormatted);
    
    
    return (timeFormatted);
    
    
}

+ (NSDate *)resetToBaseTime: (NSDate *)dateTime {
    
    
    // take the given dateTime and reset it to 8:00 am of the same day
    
    NSString *dayDate = [Event returnDateString:dateTime];
    
    NSLog(@"the day to set to basetime is %@", dayDate);
    
    // now set the viewNSDate time to 8:00 am
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    
    NSString *monthStr = [dayDate substringToIndex:2];
    NSString *dayStr   = [dayDate substringWithRange:NSMakeRange(2, 2)];
    NSString *yearStr  = [dayDate substringFromIndex:4];
    
    [components setDay:[dayStr intValue]];
    [components setMonth:[monthStr intValue]];
    [components setYear:[yearStr intValue]];
    [components setHour:8];
    [components setMinute:0];
    
    NSDate *timeFormatted = [gregorian dateFromComponents:components];
    
    NSLog(@"base time is %@", timeFormatted);
    
    return (timeFormatted);
    
    
}

+ (NSString *)JSONEventTime: (NSDate *)dateTime {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    //[formatter setDateFormat:@"kk:mm"];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];

    //Optionally for time zone converstions
    //[formatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
    
    NSString *timeFormatted = [formatter stringFromDate:dateTime];
    
    return (timeFormatted);
    
    
}

+ (NSDate *)dateFromJSONString: (NSString *)dateString {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    //[formatter setDateFormat:@"kk:mm"];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
    
    //Optionally for time zone converstions
    //[formatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
    
    NSDate *returnDate = [formatter dateFromString:dateString];
    
    return (returnDate);
    
    
}



@end
