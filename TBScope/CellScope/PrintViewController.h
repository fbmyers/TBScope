//
//  PrintViewController.h
//  TBScope
//
//  Created by Frankie Myers on 4/11/14.
//  Copyright (c) 2014 UC Berkeley Fletcher Lab. All rights reserved.
//
//  This view controller handles printing to a printer on the local network and/or emailing a PDF version of the exam registry.

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import <MessageUI/MessageUI.h>
#import "TBScopeData.h"

//default geometries for the printed page
#define PDF_PAGE_HEIGHT 612.0
#define PDF_PAGE_WIDTH 792.0
#define PDF_PAGE_MARGIN_SIDE 40.0
#define PDF_PAGE_MARGIN_TOPBOTTOM 60.0
#define PDF_LINE_SPACING 15.0

#define PDF_EXAMID_WIDTH 0.15
#define PDF_PATIENTID_WIDTH 0.15
#define PDF_PATIENTNAME_WIDTH 0.20
#define PDF_LOCATION_WIDTH 0.2
#define PDF_SLIDERESULT_WIDTH 0.05
#define PDF_SLIDERESULT_MARGIN 0.01
#define PDF_DATE_WIDTH 0.1

#define PDF_FONT_SIZE 10



@interface PrintViewController : UIViewController <MFMailComposeViewControllerDelegate, UIPrintInteractionControllerDelegate, UIDocumentInteractionControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIWebView *pdfPreviewWebView;
@property (weak, nonatomic) IBOutlet UIButton *emailButton;
@property (weak, nonatomic) IBOutlet UIButton *printButton;

@property (strong,nonatomic) NSURL* pdfURL;

@end
