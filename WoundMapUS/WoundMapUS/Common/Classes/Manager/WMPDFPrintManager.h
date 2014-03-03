//
//  WMPDFPrintManager.h
//  WoundMapUS
//
//  Created by Todd Guion on 3/3/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kPrintTemplateTwoColumnsSOAP,
    kPrintTemplateTwoColumnsTwoPhotos,
} PrintTemplate;

typedef void (^OnPrintFinish)(BOOL completed, NSError *error);

@class WMPatient, PrintConfiguration;

@interface WMPDFPrintManager : NSObject <UIPrintInteractionControllerDelegate>

+ (WMPDFPrintManager *)sharedInstance;

@property (readonly, nonatomic) NSInteger numberOfTemplates;
@property (readonly, nonatomic) BOOL hasMoreThanOneTemplate;
@property (readonly, nonatomic) NSArray *templateTitles;

- (NSString *)templateTitleForPrintTemplate:(PrintTemplate)printTemplate;

- (NSURL *)pdfURLForPatient:(WMPatient *)patient;
- (void)drawPDFToURL:(NSURL *)url forPatient:(WMPatient *)patient printConfiguration:(PrintConfiguration *)printConfiguration;
- (void)printURL:(NSURL *)url patient:(WMPatient *)patient fromBarButtonItem:(UIBarButtonItem *)barButtonItem onPrintFinish:(OnPrintFinish)onPrintFinish;

@end
