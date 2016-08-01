//
//  AppDelegate.m
//  SmoothPay2.0
//
//  Created by Alex on 11/12/15.
//  Copyright (c) 2015 BCL. All rights reserved.
//

#import "AppDelegate.h"
#import "XWaitingAlert.h"
#import "WebCacheManager.h"
#import "RequestService.h"
#import "RD_Result.h"
#import "SplashViewController.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <AdColony/AdColony.h>
#import <Google/Analytics.h>

@interface AppDelegate ()

@property (nonatomic, retain) UINavigationController *  navVC;
@property (nonatomic, retain) XWaitingAlert *           waitingAlert;

@end

@implementation AppDelegate

+ (AppDelegate *) sharedDelegate {
    
    return (AppDelegate *) [[UIApplication sharedApplication] delegate];
}

- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [Fabric with:@[[Crashlytics class]]];
    [WebCacheManager sharedInstance];
    
    // Configure tracker from GoogleService-Info.plist.
    NSError * configureError;
    [[GGLContext sharedInstance] configureWithError:&configureError];
    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
    
    // Optional: configure GAI options.
    GAI * gai = [GAI sharedInstance];
    [gai trackerWithTrackingId:@"UA-51014242-21"];
    gai.trackUncaughtExceptions = YES;  // report uncaught exceptions
    
    self.mainVC = [MainViewController newInstance];
    self.navVC = [[UINavigationController alloc] initWithRootViewController:_mainVC];
    _navVC.navigationBarHidden = YES;
    _navVC.interactivePopGestureRecognizer.enabled = NO;
    
    SplashViewController * splashVC = [SplashViewController newInstance];
    [_navVC pushViewController:splashVC animated:NO];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [_window addSubview:_navVC.view];
    [_window setRootViewController:_navVC];
    [_window makeKeyAndVisible];
    
    [self initApp:application];
    
    [_mainVC refreshListAll];
    
    return YES;
}

- (void) initApp:(UIApplication *)application {
    
    if (appSetting().firstLaunch) {
        
        appSetting().firstLaunch = NO;
        appSetting().userId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    }
    
    // iOS 8 Notications
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                        UIUserNotificationTypeBadge |
                                                        UIUserNotificationTypeSound);
        UIUserNotificationSettings * settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                  categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    }
    else {
        
        // Register for Push Notifications before iOS 8
        [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                         UIRemoteNotificationTypeAlert |
                                                         UIRemoteNotificationTypeSound)];
    }
    
    application.applicationIconBadgeNumber = 0;
    
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    //*********** Register For Remote notification ***************//
    
    NSLog(@"devToken=%@", deviceToken);
    NSString * devToken = [deviceToken description];
    NSCharacterSet * notAllowedChars = [NSCharacterSet characterSetWithCharactersInString:@"<>"] ;
    devToken = [[devToken componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""];
    devToken = [devToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"devToken=%@" ,devToken);
    
    appSetting().pushId = devToken;
    
//    if (!appSetting().registered) {
    
        [RequestService requestRegister:appSetting().userId iosId:appSetting().pushId respondBlock:^(RD_Base *respond, NSError *error) {
            
            RD_Result * result = (RD_Result *) respond;
            
            if (result.result == RDResultSuccess) {
                
                appSetting().registered = YES;
            }
        }];
//    }
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err
{
    NSLog(@"Error in registration. Error: %@", err);
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void) showWaitingAlert:(BOOL)show message:(NSString *)message {
    
    if (show) {
        
        if (self.waitingAlert == nil) {
            
            self.waitingAlert = [[XWaitingAlert alloc] initWithView:self.window];
            _waitingAlert.dimBackground = YES;
            
            [self.window addSubview:_waitingAlert];
        }
        
        _waitingAlert.labelText = message;
        
        [_window bringSubviewToFront:_waitingAlert];
        [_waitingAlert show:YES];
    }
    else if (_waitingAlert) {
        
        [_waitingAlert hide:YES];
    }
}

@end
