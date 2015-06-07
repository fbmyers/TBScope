//
//  SlideListTableViewCell.h
//  TBScope
//
//  Created by Frankie Myers on 1/9/14.
//  Copyright (c) 2014 UC Berkeley Fletcher Lab. All rights reserved.
//
//  A single cell in the ExamListViewController, representing all the summary data the user needs to be able to select an exam.

#import <UIKit/UIKit.h>

@interface ExamListTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *examIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *patientIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *patientNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;

@property (weak, nonatomic) IBOutlet UILabel *scoreLabel1;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel2;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel3;

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet UIImageView *syncIcon;

@end
