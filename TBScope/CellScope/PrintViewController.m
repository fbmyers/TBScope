//
//  PrintViewController.m
//  TBScope
//
//  Created by Frankie Myers on 4/11/14.
//  Copyright (c) 2014 UC Berkeley Fletcher Lab. All rights reserved.
//

#import "PrintViewController.h"


@interface PrintViewController ()

@end

@implementation PrintViewController


UITapGestureRecognizer* recognizer;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createPDFRegistry];
    
    
    [TBScopeData CSLog:@"Generated PDF registry." inCategory:@"USER"];
    
    [self displayRegistry];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    //cancel this modal view if user taps background
    recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapBehind:)];
    [recognizer setNumberOfTapsRequired:1];
    recognizer.cancelsTouchesInView = NO; //So the user can still interact with controls in the modal view
    [self.view.window addGestureRecognizer:recognizer];
    
    [TBScopeData CSLog:@"Print screen presented." inCategory:@"USER"];
}

- (void)handleTapBehind:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        CGPoint location = [sender locationInView:nil]; //Passing nil gives us coordinates in the window
        
        //Then we convert the tap's location into the local view's coordinate system, and test to see if it's in or outside. If outside, dismiss the view.
        if (![self.view pointInside:[self.view convertPoint:location fromView:self.view.window] withEvent:nil])
        {
            [self dismissPrintViewController];
        }
    }
}

- (void) dismissPrintViewController
{
    [self.view.window removeGestureRecognizer:recognizer];
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)didPressPrint:(id)sender
{
    if ([UIPrintInteractionController isPrintingAvailable])
    {

        NSData* pdfData = [NSData dataWithContentsOfFile:[self.pdfURL path]];
        
        UIPrintInteractionController *pic = [UIPrintInteractionController sharedPrintController];
        pic.delegate = self;
        UIPrintInfo *printInfo = [UIPrintInfo printInfo];
        printInfo.outputType = UIPrintInfoOutputGeneral;
        printInfo.jobName = @"TB Registry";
        printInfo.duplex = UIPrintInfoDuplexLongEdge;
        pic.printInfo = printInfo;
        pic.showsPageRange = YES;
        pic.printingItem = pdfData;
        void (^completionHandler)(UIPrintInteractionController *, BOOL, NSError *) =
        ^(UIPrintInteractionController *printController, BOOL completed, NSError *error) {
            if (!completed && error) {
                NSLog(@"Printing could not complete because of error: %@", error);
            }
            else {
                [TBScopeData CSLog:@"Printing registry." inCategory:@"USER"];    
            }
            [pic dismissAnimated:YES];
            [self.view.window addGestureRecognizer:recognizer];
        };
        
        [self.view.window removeGestureRecognizer:recognizer];
        [pic presentFromRect:self.printButton.bounds inView:self.printButton animated:YES completionHandler:completionHandler];
         
    }
}

- (IBAction)didPressEmail:(id)sender
{
    
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    [df setDateStyle:NSDateFormatterShortStyle];
    [df setTimeStyle:NSDateFormatterShortStyle];
    NSString* dateString = [df stringFromDate:[NSDate date]];
    
    NSString *emailSubject = @"CellScope TB Registry";
    // Email Content

    
    NSString *emailBody = [NSString stringWithFormat:@"CellScope TB Registry\nDate Prepared: %@\nPrepared By:%@\nLocation: %@\nCellScope ID: %@\n\nDate Range: %@\n",
                             dateString,
                             [[[TBScopeData sharedData] currentUser] username],
                             [[NSUserDefaults standardUserDefaults] stringForKey:@"DefaultLocation"],
                             [[NSUserDefaults standardUserDefaults] stringForKey:@"CellScopeID"],
                              @"ALL"];

    
    // To address
    NSArray *toRecipients = [NSArray arrayWithObject:[[NSUserDefaults standardUserDefaults] stringForKey:@"DefaultEmailRecipient"]];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    
    if (mc==nil) { //the user hasn't yet set up a mail account on this iPad, so return to avoid crash
        return;
    }
    
    mc.mailComposeDelegate = self;
    [mc setSubject:emailSubject];
    [mc setMessageBody:emailBody isHTML:NO];
    [mc setToRecipients:toRecipients];
    
    NSData* pdfData = [NSData dataWithContentsOfFile:[self.pdfURL path]];
    
    [df setTimeStyle:NSDateFormatterNoStyle];
    
    NSString* filename = [NSString stringWithFormat:@"TB Registry - %@ - %@.pdf",
                          [[NSUserDefaults standardUserDefaults] stringForKey:@"CellScopeID"],
                          [df stringFromDate:[NSDate date]]];
    [mc addAttachmentData:pdfData mimeType:@"application/pdf" fileName:filename];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
    [self.view.window removeGestureRecognizer:recognizer];
}


- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            [TBScopeData CSLog:@"Email canceled" inCategory:@"PRINT"];
            break;
        case MFMailComposeResultSaved:
            [TBScopeData CSLog:@"Email saved" inCategory:@"PRINT"];
            break;
        case MFMailComposeResultSent:
            [TBScopeData CSLog:@"Email sent" inCategory:@"PRINT"];
            break;
        case MFMailComposeResultFailed:
            [TBScopeData CSLog:[NSString stringWithFormat:@"Email send failure: %@",error.description] inCategory:@"PRINT"];
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
    [self.view.window addGestureRecognizer:recognizer];
}

- (void)createPDFRegistry
{
    
    NSURL* applicationDocumentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    self.pdfURL = [applicationDocumentsDirectory URLByAppendingPathComponent:@"registry.pdf"];

    UIGraphicsBeginPDFContextToFile([self.pdfURL path], CGRectZero, nil);

    NSArray* examList = [CoreDataHelper getObjectsForEntity:@"Exams" withSortKey:@"dateModified" andSortAscending:NO andContext:[[TBScopeData sharedData] managedObjectContext]];

    
    float lineNum = 0;
    for (Exams* ex in examList)
    {
        if (lineNum>(PDF_PAGE_HEIGHT-PDF_PAGE_MARGIN_TOPBOTTOM) || lineNum==0) {
            lineNum = [self startNewPage];
        }
        lineNum = [self drawExam:ex atLine:lineNum];
    }

    // Close the PDF context and write the contents out.
    UIGraphicsEndPDFContext();
    
}

- (void)drawPageNumber:(NSInteger)pageNum
{
    NSString *pageString = [NSString stringWithFormat:@"Page %d", pageNum];
    UIFont *theFont = [UIFont systemFontOfSize:12];
    CGSize maxSize = CGSizeMake(612, 72);
    
    CGSize pageStringSize = [pageString sizeWithFont:theFont
                                   constrainedToSize:maxSize
                                       lineBreakMode:UILineBreakModeClip];
    CGRect stringRect = CGRectMake(((612.0 - pageStringSize.width) / 2.0),
                                   720.0 + ((72.0 - pageStringSize.height) / 2.0),
                                   pageStringSize.width,
                                   pageStringSize.height);
    
    [pageString drawInRect:stringRect withFont:theFont];
}

- (float)startNewPage
{
    UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, PDF_PAGE_WIDTH, PDF_PAGE_HEIGHT), nil); //landscape?
    
    float col;
    float width;
    float lineNum = PDF_PAGE_MARGIN_TOPBOTTOM;
    
    UIFont* font = [UIFont systemFontOfSize:PDF_FONT_SIZE];
    
    col = PDF_PAGE_MARGIN_SIDE;
    [@"CellScope TB Registry" drawInRect:CGRectMake(col,lineNum,PDF_PAGE_WIDTH,PDF_LINE_SPACING) withFont:font];
    lineNum = lineNum + PDF_LINE_SPACING;
    
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    [df setDateStyle:NSDateFormatterShortStyle];
    [df setTimeStyle:NSDateFormatterShortStyle];
    NSString* dateString = [df stringFromDate:[NSDate date]];
    NSString* currentUser = [[[TBScopeData sharedData] currentUser] username];
    [[NSString stringWithFormat:@"Printed on %@ by %@",dateString,currentUser] drawInRect:CGRectMake(col,lineNum,PDF_PAGE_WIDTH,PDF_LINE_SPACING) withFont:font];
    lineNum = lineNum + PDF_LINE_SPACING*2;
    

    width = PDF_EXAMID_WIDTH*(PDF_PAGE_WIDTH-2*PDF_PAGE_MARGIN_SIDE);
    [@"Exam #" drawInRect:CGRectMake(col,lineNum,width,PDF_LINE_SPACING) withFont:font];
    
    col = col + width;
    width = PDF_PATIENTID_WIDTH*(PDF_PAGE_WIDTH-2*PDF_PAGE_MARGIN_SIDE);
    [@"Patient #" drawInRect:CGRectMake(col,lineNum,width,PDF_LINE_SPACING) withFont:font];
    
    col = col + width;
    width = PDF_PATIENTNAME_WIDTH*(PDF_PAGE_WIDTH-2*PDF_PAGE_MARGIN_SIDE);
    [@"Name" drawInRect:CGRectMake(col,lineNum,width,PDF_LINE_SPACING) withFont:font];
    
    col = col + width;
    width = PDF_LOCATION_WIDTH*(PDF_PAGE_WIDTH-2*PDF_PAGE_MARGIN_SIDE);
    [@"Clinic" drawInRect:CGRectMake(col,lineNum,width,PDF_LINE_SPACING) withFont:font];
    
    col = col + width;
    width = (PDF_SLIDERESULT_WIDTH*3+PDF_SLIDERESULT_MARGIN*3)*(PDF_PAGE_WIDTH-2*PDF_PAGE_MARGIN_SIDE);
    [@"Results" drawInRect:CGRectMake(col,lineNum,width,PDF_LINE_SPACING) withFont:font];
    
    col = col + width;
    width = PDF_DATE_WIDTH*(PDF_PAGE_WIDTH-2*PDF_PAGE_MARGIN_SIDE);
    [@"First Collection Date" drawInRect:CGRectMake(col,lineNum,width,PDF_LINE_SPACING) withFont:font];
    
    lineNum = lineNum + PDF_LINE_SPACING;
    
    draw1PxStroke(UIGraphicsGetCurrentContext(), CGPointMake(PDF_PAGE_MARGIN_SIDE,lineNum), CGPointMake(PDF_PAGE_WIDTH-PDF_PAGE_MARGIN_SIDE,lineNum), [UIColor blackColor].CGColor);
    
    lineNum = lineNum + PDF_LINE_SPACING;
    
    
    return lineNum;
}

- (float)drawExam:(Exams*)ex atLine:(float)lineNum
{
    float col;
    float width;
    UIFont* font = [UIFont systemFontOfSize:PDF_FONT_SIZE];
    
    col = PDF_PAGE_MARGIN_SIDE;
    width = PDF_EXAMID_WIDTH*(PDF_PAGE_WIDTH-2*PDF_PAGE_MARGIN_SIDE);
    [ex.examID drawInRect:CGRectMake(col,lineNum,width,PDF_LINE_SPACING) withFont:font];
    
    col = col + width;
    width = PDF_PATIENTID_WIDTH*(PDF_PAGE_WIDTH-2*PDF_PAGE_MARGIN_SIDE);
    [ex.patientID drawInRect:CGRectMake(col,lineNum,width,PDF_LINE_SPACING) withFont:font];
    
    col = col + width;
    width = PDF_PATIENTNAME_WIDTH*(PDF_PAGE_WIDTH-2*PDF_PAGE_MARGIN_SIDE);
    [ex.patientName drawInRect:CGRectMake(col,lineNum,width,PDF_LINE_SPACING) withFont:font];
    
    col = col + width;
    width = PDF_LOCATION_WIDTH*(PDF_PAGE_WIDTH-2*PDF_PAGE_MARGIN_SIDE);
    [ex.location drawInRect:CGRectMake(col,lineNum,width,PDF_LINE_SPACING) withFont:font];
    
    col = col + width;
    width = PDF_SLIDERESULT_WIDTH*(PDF_PAGE_WIDTH-2*PDF_PAGE_MARGIN_SIDE);
    [self drawSlideScore:0 fromExam:ex atLine:lineNum column:col width:width font:font];
    
    col = col + width + PDF_SLIDERESULT_MARGIN*(PDF_PAGE_WIDTH-2*PDF_PAGE_MARGIN_SIDE);
    [self drawSlideScore:1 fromExam:ex atLine:lineNum column:col width:width font:font];
    
    col = col + width + PDF_SLIDERESULT_MARGIN*(PDF_PAGE_WIDTH-2*PDF_PAGE_MARGIN_SIDE);
    [self drawSlideScore:2 fromExam:ex atLine:lineNum column:col width:width font:font];
    
    
    // collection date
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    [df setDateStyle:NSDateFormatterShortStyle];
    [df setTimeStyle:NSDateFormatterShortStyle];
    NSString* dateString = @"N/A";
    if (ex.examSlides.count>0)
        dateString = [df stringFromDate:[TBScopeData dateFromString:((Slides*)ex.examSlides[0]).dateCollected]];
    
    col = col + width + PDF_SLIDERESULT_MARGIN*(PDF_PAGE_WIDTH-2*PDF_PAGE_MARGIN_SIDE);
    width = PDF_DATE_WIDTH*(PDF_PAGE_WIDTH-2*PDF_PAGE_MARGIN_SIDE);
    [dateString drawInRect:CGRectMake(col,lineNum,width,PDF_LINE_SPACING) withFont:font];
    
    
    return lineNum+PDF_LINE_SPACING;
    

    
}

- (void)drawSlideScore:(int)slideNum fromExam:(Exams*)ex atLine:(float)lineNum column:(float)col width:(float)width font:(UIFont*)font
{
    float score = 0.0;
    NSString* scoreString = @"";
    if ((ex.examSlides.count)>slideNum)
    {
        scoreString = @"N/A";
        if (((Slides*)ex.examSlides[slideNum]).slideAnalysisResults!=nil)
        {
            score = ((Slides*)ex.examSlides[slideNum]).slideAnalysisResults.score;
            scoreString = [NSString stringWithFormat:@"%2.2f",score*100];
        }
    }
    
    if (score>[[NSUserDefaults standardUserDefaults] floatForKey:@"DiagnosticThreshold"])
        CGContextStrokeRect(UIGraphicsGetCurrentContext(),CGRectMake(col,lineNum,width,PDF_LINE_SPACING*0.8));

    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    
    NSDictionary *attr = @{ NSFontAttributeName: font,
                                  NSParagraphStyleAttributeName: paragraphStyle,
                                  NSForegroundColorAttributeName: [UIColor blackColor]};
    
    [scoreString drawInRect:CGRectMake(col,lineNum,width,PDF_LINE_SPACING) withAttributes:attr];
    
}

- (void)displayRegistry
{
   
    NSURLRequest *request = [NSURLRequest requestWithURL:self.pdfURL];
    [self.pdfPreviewWebView loadRequest:request];
    
}


void draw1PxStroke(CGContextRef context, CGPoint startPoint, CGPoint endPoint, CGColorRef color)
{
    CGContextSaveGState(context);
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetStrokeColorWithColor(context, color);
    CGContextSetLineWidth(context, 1.0);
    CGContextMoveToPoint(context, startPoint.x + 0.5, startPoint.y + 0.5);
    CGContextAddLineToPoint(context, endPoint.x + 0.5, endPoint.y + 0.5);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
}

@end
