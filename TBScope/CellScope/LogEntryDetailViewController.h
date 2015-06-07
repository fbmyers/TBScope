//
//  LogEntryDetailViewController.h
//  TBScope
//
//  Created by Frankie Myers on 10/11/2014.
//  Copyright (c) 2014 UC Berkeley Fletcher Lab. All rights reserved.
//
//  Displays a log entry message in full screen.

#import <UIKit/UIKit.h>
#import "TBScopeData.h"


@interface LogEntryDetailViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextView *logEntryTextView;

@property (strong,nonatomic) Logs* currentLogEntry;

@end
