//
//  NowWhatDetailViewController.h
//  NowWhat
//
//  Created by Rich Humphrey on 10/14/13.
//  Copyright (c) 2013 Rich Humphrey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UnmanagedEvent.h"
#import "Event.h"

@interface NowWhatDetailViewController : UIViewController <UISplitViewControllerDelegate, UIWebViewDelegate> {
    
    NSInteger webViewOffset;
    
}

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@property (nonatomic, retain) IBOutlet UIWebView *eventDisplayWebView;
@property (nonatomic, retain) IBOutlet UILabel *countdownLabel;


@property (nonatomic, retain) NSString *viewDate;
@property (nonatomic, retain) NSDate *viewNSDate;
@property (nonatomic, retain) NSString *viewSchedule;
@property (nonatomic, retain) NSMutableArray *dayData;


@end
