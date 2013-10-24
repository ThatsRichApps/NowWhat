//
//  TemplateCell.m
//  NowWhat
//
//  Created by Rich Humphrey on 10/23/13.
//  Copyright (c) 2013 Rich Humphrey. All rights reserved.
//

#import "TemplateCell.h"

@implementation TemplateCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
