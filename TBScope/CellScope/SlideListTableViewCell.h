//
//  SlideListTableViewCell.h
//  TBScope
//
//  Created by Frankie Myers on 1/9/14.
//  Copyright (c) 2014 UC Berkeley Fletcher Lab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SlideListTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *patientIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *patientNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end
