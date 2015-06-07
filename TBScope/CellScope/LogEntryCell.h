//
//  LogEntryCell.h
//  TBScope
//
//  Created by Frankie Myers on 10/11/2014.
//  Copyright (c) 2014 UC Berkeley Fletcher Lab. All rights reserved.
//
//  Represents a single line in the log entry view controller

#import <UIKit/UIKit.h>

@interface LogEntryCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end
