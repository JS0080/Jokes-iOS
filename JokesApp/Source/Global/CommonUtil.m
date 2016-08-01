//
//  CommonUtil.m
//  SmoothPay2.0
//
//  Created by Alex on 11/12/15.
//  Copyright (c) 2015 BCL. All rights reserved.
//

#import "CommonUtil.h"
#import "AppDelegate.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>
#import "RequestServiceDefines.h"
#import <PassKit/PassKit.h>
#import "UIAlertView+Block.h"

@implementation CommonUtil

#pragma mark - Application Directory Functions
#pragma mark -
+ (NSURL *) applicationDocumentsDirectoryURL {
    
    return [NSURL fileURLWithPath:[CommonUtil applicationDocumentsDirectory]];
}

+ (NSString *) applicationDocumentsDirectory {
    
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    
//    basePath = [basePath stringByAppendingPathComponent:[NSString stringWithFormat:@"user%@", appSetting.userId]];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:basePath]) {
        
        [[NSFileManager defaultManager] createDirectoryAtPath:basePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return basePath;
}

#pragma mark - Validation Fuctions
#pragma mark -
+ (BOOL) validatePhoneNumber:(NSString *)phoneNumber {
    
    NSDataDetector * detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypePhoneNumber error:nil];
    NSArray * matches = [detector matchesInString:phoneNumber options:0 range:NSMakeRange(0, [phoneNumber length])];
    
    return [matches count] > 0;
}

+ (BOOL) validateEmailAddress:(NSString *)emailAddress {
    emailAddress = [emailAddress stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString * emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
    NSPredicate * emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:emailAddress];
}

#pragma mark - Waiting Alert Function
#pragma mark -
+ (void) showWaitingAlert:(NSString *)message {
    
    [[AppDelegate sharedDelegate] showWaitingAlert:YES message:message];
}

+ (void) hideWaitingAlert {
    
    [[AppDelegate sharedDelegate] showWaitingAlert:NO message:nil];
}

+ (float) version {
    
    NSString *versionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
    return [versionString floatValue];
}

+ (NSString *) versionString {
    
    NSString *versionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    return [NSString stringWithFormat:@"iOS%@", versionString];
}

+ (NSString *) stringFromDate1:(NSDate *)date {
    
    NSDate * today = [NSDate date];
    NSDate * yesterday = [NSDate dateWithTimeIntervalSinceNow:-86400]; //86400 is the seconds in a day
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    NSLocale *        enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    
    [formatter setLocale:enUSPOSIXLocale];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString * todayString = [formatter stringFromDate:today];
    NSString * yesterdayString = [formatter stringFromDate:yesterday];
    NSString * refDateString = [formatter stringFromDate:date];
    
    if ([refDateString isEqualToString:todayString])
        return @"Today";
    else if ([refDateString isEqualToString:yesterdayString])
        return @"Yesterday";
    
    [formatter setDateFormat:@"MMM d, yyyy"];
    return [formatter stringFromDate:date];
}

+ (BOOL) isInternetConnected {
    
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*)&zeroAddress);
    if (reachability != NULL) {
        
        //NetworkStatus retVal = NotReachable;
        SCNetworkReachabilityFlags flags;
        if (SCNetworkReachabilityGetFlags(reachability, &flags)) {
            
            if ((flags & kSCNetworkReachabilityFlagsReachable) == 0) {
                
                // if target host is not reachable
                return NO;
            }
            
            if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0) {
                
                // if target host is reachable and no connection is required
                //  then we'll assume (for now) that your on Wi-Fi
                return YES;
            }
            
            if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
                 (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0)) {
                
                // ... and the connection is on-demand (or on-traffic) if the
                //     calling application is using the CFSocketStream or higher APIs
                
                if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0) {
                    
                    // ... and no [user] intervention is needed
                    return YES;
                }
            }
            
            if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN) {
                
                // ... but WWAN connections are OK if the calling application
                //     is using the CFNetwork (CFSocketStream?) APIs.
                return YES;
            }
        }
    }
    
    return NO;
}

+ (void) showLocationMsg {
    
    [[[UIAlertView alloc] initWithTitle:@"" message:@"SmoothPay requires your location. Please enable Location Services on Setting" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] showWithCancelBlock:^(NSInteger buttonIndex) {
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }];
}

@end
