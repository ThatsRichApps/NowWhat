//
//  AddScheduleViewController.h
//  NowWhat
//
//  Created by Rich Humphrey on 11/1/13.
//  Copyright (c) 2013 Rich Humphrey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Schedule.h"



@class AddScheduleViewController;

@protocol AddScheduleViewControllerDelgate <NSObject>

- (void)addScheduleView:(AddScheduleViewController *)controller addSchedule:(NSString *)scheduleName;

@end


@interface AddScheduleViewController : UITableViewController {
    
    
    IBOutlet UITextField *scheduleField;

}

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, weak) id <AddScheduleViewControllerDelgate> delegate;


- (IBAction)cancel;
- (IBAction)save;


@end
