//
//  TemplateEvent.h
//  NowWhat
//
//  Created by Rich Humphrey on 10/21/13.
//  Copyright (c) 2013 Rich Humphrey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TemplateEvent : NSManagedObject

@property (nonatomic, retain) NSDate * eventTime;
@property (nonatomic, retain) NSString * eventText;
@property (nonatomic, retain) NSString * eventNotes;
@property (nonatomic, retain) NSManagedObject *template;

@end
