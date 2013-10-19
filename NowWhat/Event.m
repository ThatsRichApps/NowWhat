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
@dynamic eventSchedule;


- (void)toggleChecked    {
    self.eventChecked = !self.eventChecked;
}



- (NSString *)formattedTime {
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //[formatter setDateFormat:@"yyyy"];
    [formatter setDateFormat:@"hh:mm a"];
    
    //Optionally for time zone converstions
    //[formatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
    
    NSString *timeFormatted = [formatter stringFromDate:self.eventNSDate];

    return (timeFormatted);
    
    
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

+ (NSString *)returnDate: (NSDate *)dateTime {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //[formatter setDateFormat:@"yyyy"];
    [formatter setDateFormat:@"MMddYYYY"];
    
    //Optionally for time zone converstions
    //[formatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
    
    NSString *dateFormatted = [formatter stringFromDate:dateTime];
    
    return (dateFormatted);
    
    
}




@end
