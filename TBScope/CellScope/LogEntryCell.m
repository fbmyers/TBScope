//
//  LogEntryCell.m
//  TBScope
//
//  Created by Frankie Myers on 10/11/2014.
//  Copyright (c) 2014 UC Berkeley Fletcher Lab. All rights reserved.
//

#import "LogEntryCell.h"

@implementation LogEntryCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
