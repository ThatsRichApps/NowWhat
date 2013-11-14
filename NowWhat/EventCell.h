//
//  EventCell.h
//  NowWhat
//
//  Created by Rich Humphrey on 10/17/13.
//  Copyright (c) 2013 Rich Humphrey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *eventTimeLabel;
@property (nonatomic, strong) IBOutlet UILabel *eventNotesLabel;
@property (nonatomic, strong) IBOutlet UILabel *eventCheckLabel;
@property (nonatomic, strong) IBOutlet UILabel *eventTextLabel;
@property (nonatomic, strong) IBOutlet UITextView *eventNotesView;
@property (nonatomic, strong) IBOutlet UILabel *eventEndTimeLabel;


@end
