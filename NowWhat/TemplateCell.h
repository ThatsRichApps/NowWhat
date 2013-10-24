//
//  TemplateCell.h
//  NowWhat
//
//  Created by Rich Humphrey on 10/23/13.
//  Copyright (c) 2013 Rich Humphrey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TemplateCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *templateNameLabel;
@property (nonatomic, assign) int *templateListOrder;


@end
