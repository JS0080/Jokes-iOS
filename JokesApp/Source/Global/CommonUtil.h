//
//  CommonUtil.h
//  SmoothPay2.0
//
//  Created by Alex on 11/12/15.
//  Copyright (c) 2015 BCL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define IS_OS_8_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@interface CommonUtil : NSObject

+ (NSURL *) applicationDocumentsDirectoryURL;
+ (NSString *) applicationDocumentsDirectory;

+ (BOOL) validatePhoneNumber:(NSString *)phoneNumber;
+ (BOOL) validateEmailAddress:(NSString *)emailAddress;

+ (void) showWaitingAlert:(NSString *)message;
+ (void) hideWaitingAlert;

+ (NSString *) versionString;
+ (float) version;
+ (NSString *) stringFromDate1:(NSDate *)date;

+ (BOOL) isInternetConnected;

+ (void) showLocationMsg;

@end
