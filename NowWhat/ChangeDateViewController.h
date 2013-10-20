//
//  ChangeDateViewController.h
//  NowWhat
//
//  Created by Rich Humphrey on 10/20/13.
//  Copyright (c) 2013 Rich Humphrey. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ChangeDateViewController;

@protocol ChangeDateViewControllerDelgate <NSObject>

- (void)changeDatePicker:(ChangeDateViewController *)controller didChangeDate:(NSDate *)newDate;

@end


@interface ChangeDateViewController : UIViewController {
    
    IBOutlet UIButton *backToToday;
    IBOutlet UIDatePicker *eventDatePicker;
    IBOutlet UILabel *dayOfTheWeek;
    
}

@property (nonatomic, weak) id <ChangeDateViewControllerDelgate> delegate;
@property (nonatomic, strong) NSDate *selectedDate;

-(IBAction) resetDatePicker;
-(IBAction) changeDayOfTheWeek;

- (IBAction)cancel;
- (IBAction)save;


@end
