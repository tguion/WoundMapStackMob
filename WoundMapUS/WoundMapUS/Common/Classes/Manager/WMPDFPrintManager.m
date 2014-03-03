//
//  WMPDFPrintManager.m
//  WoundMapUS
//
//  Created by Todd Guion on 3/3/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMPDFPrintManager.h"
#import "WMPatient.h"
#import "WCAppDelegate.h"

@interface WMPDFPrintManager()

@property (readonly, nonatomic) WCAppDelegate *appDelegate;

@end

@implementation WMPDFPrintManager

+ (WMPDFPrintManager *)sharedInstance
{
    static WMPDFPrintManager *SharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SharedInstance = [[WMPDFPrintManager alloc] init];
    });
    return SharedInstance;
}

- (WCAppDelegate *)appDelegate{
    return (WCAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (NSInteger)numberOfTemplates
{
    return [self.templateTitles count];
}

- (BOOL)hasMoreThanOneTemplate
{
    return (self.numberOfTemplates > 1);
}

- (NSArray *)templateTitles
{
    return [NSArray arrayWithObjects:@"SOAP", nil]; // @"Two Columns - Two Photos"
}

- (NSString *)templateTitleForPrintTemplate:(PrintTemplate)printTemplate
{
    return [self.templateTitles objectAtIndex:printTemplate];
}

- (void)drawPDFToURL:(NSURL *)url forPatient:(WCPatient *)patient printConfiguration:(PrintConfiguration *)printConfiguration
{
    PDFRenderer *renderer = [self rendererForPrintTemplate:printConfiguration.printTemplate];
    renderer.patient = patient;
    renderer.printConfiguration = printConfiguration;
    [renderer drawToURL:url];
}

- (NSURL *)pdfURLForPatient:(WCPatient *)patient
{
    NSString *fileName = [NSString stringWithFormat:@"%@.%@.%lf", patient.lastName, patient.firstName, [[NSDate date] timeIntervalSince1970]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *pdfDirectory = [self.appDelegate.applicationDocumentsDirectory URLByAppendingPathComponent:@"PDF"];
    if (![fileManager fileExistsAtPath:pdfDirectory.path]) {
        NSError *error = nil;
        BOOL success = [fileManager createDirectoryAtPath:pdfDirectory.path withIntermediateDirectories:YES attributes:nil error:&error];
        if (!success) {
            [WCUtilities logError:error];
        }
    }
    NSURL *url = [[pdfDirectory URLByAppendingPathComponent:fileName] URLByAppendingPathExtension:@"pdf"];
    return url;
}

- (void)printURL:(NSURL *)url patient:(WCPatient *)patient fromBarButtonItem:(UIBarButtonItem *)barButtonItem onPrintFinish:(OnPrintFinish)onPrintFinish
{
    UIPrintInteractionController *printController = [UIPrintInteractionController sharedPrintController];
    printController.delegate = self;
    UIPrintInfo *printInfo = [UIPrintInfo printInfo];
    printInfo.outputType = UIPrintInfoOutputGeneral;
    printInfo.jobName = [patient lastNameFirstName];
    printInfo.duplex = UIPrintInfoDuplexLongEdge;
    printController.printInfo = printInfo;
    printController.showsPageRange = YES;
    printController.printingItem = url;
    void (^completionHandler)(UIPrintInteractionController *,BOOL, NSError *) = ^(UIPrintInteractionController *print,BOOL completed, NSError *error) {
        onPrintFinish(completed, error);
        if (!completed && error) {
            [WCUtilities logError:error];
        }
    };
    // same call for both iPhone and IPad
    [printController presentAnimated:YES completionHandler:completionHandler];
}

#pragma mark - UIPrintInteractionControllerDelegate

@end
