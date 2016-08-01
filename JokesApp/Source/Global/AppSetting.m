//
//  AppSetting.m
//  SmoothPay2.0
//
//  Created by Alex on 11/12/15.
//  Copyright (c) 2015 BCL. All rights reserved.
//

#import "AppSetting.h"
#import <GoogleMobileAds/GoogleMobileAds.h>
#import <AdColony/AdColony.h>

@interface AppSetting () <GADInterstitialDelegate, AdColonyAdDelegate, AdColonyDelegate>

@property (nonatomic, retain) NSMutableArray *  refreshing;

@property (nonatomic, strong) GADInterstitial * adIntGoogle;
@property (nonatomic, assign) BOOL              adIntShowed;
@property (nonatomic, assign) BOOL              adIntColony;
@property (nonatomic, assign) BOOL              adColonyReady;

@end

@implementation AppSetting

+ (AppSetting *) sharedInstance {
    
    static AppSetting * instance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        instance = [[AppSetting alloc] init];
    });
    
    return instance;
}

- (void) loadSetting {
    
    _firstLaunch = [self boolForKey:@"jokekey_first_launch" defVal:YES];
    _registered  = [self boolForKey:@"jokekey_registered" defVal:NO];
    _userId      = [self stringForKey:@"jokekey_user_id" defVal:@""];
    _pushId      = [self stringForKey:@"jokekey_push_id" defVal:@""];
    _useAdmob    = [self boolForKey:@"jokekey_use_admob" defVal:NO];
    _admobType   = [self integerForKey:@"jokekey_admob_type" defVal:0];
    _admobInterval = [self integerForKey:@"jokekey_admob_interval" defVal:5];
    
    _refreshing  = [NSMutableArray arrayWithObjects:@NO, @NO, @NO, @NO, nil];
    
    _adIntGoogle = nil;
    _adIntColony = NO;
    _adIntShowed = YES;
    _adColonyReady = NO;
}

- (void) setFirstLaunch:(BOOL)firstLaunch {
    
    _firstLaunch = firstLaunch;
    [self setBool:_firstLaunch forKey:@"jokekey_first_launch"];
}

- (void) setRegistered:(BOOL)registered {
    
    _registered = registered;
    [self setBool:_registered forKey:@"jokekey_registered"];
}

- (void) setUserId:(NSString *)userId {
    
    _userId = userId;
    [self setString:_userId forKey:@"jokekey_user_id"];
}

- (void) setPushId:(NSString *)pushId {
    
    _pushId = pushId;
    [self setString:_pushId forKey:@"jokekey_push_id"];
}

- (void) setUseAdmob:(BOOL)useAdmob {

    _useAdmob = useAdmob;
    [self setBool:_useAdmob forKey:@"jokekey_use_admob"];
}

- (void) setAdmobType:(NSInteger)admobType {
    
    _admobType = admobType;
    [self setInteger:_admobType forKey:@"jokekey_admob_type"];
}

- (void) setAdmobInterval:(NSInteger)admobInterval {
    
    _admobInterval = admobInterval;
    [self setInteger:_admobInterval forKey:@"jokekey_admob_interval"];
}

- (void) setRefreshing:(BOOL)refreshing category:(NSInteger)category {
    
    _refreshing[category] = @(refreshing);
}

- (BOOL) refreshing:(NSInteger)category {
    
    return [_refreshing[category] boolValue];
}

- (void) setQuoteList:(RD_QuoteList *)list category:(NSInteger)category {
    
    switch (category) {
        case 0:
            self.listHot = list;
            break;
            
        case 1:
            self.listNew = list;
            break;
            
        case 2:
            self.listTop = list;
            break;
            
        case 3:
            self.listFav = list;
            break;
            
        default:
            break;
    }
}

- (RD_QuoteList *) quoteList:(NSInteger)category {
    
    switch (category) {
        case 0:
            return self.listHot;
            
        case 1:
            return self.listNew;
            
        case 2:
            return self.listTop;
            
        case 3:
            return self.listFav;
            
        default:
            break;
    }
    
    return nil;
}

- (void) increaseMoveCnt {
    
    [self createAndLoadInterstitial];
    
    _moveCnt ++;
    NSLog(@"Increase Move Count to %d", (int) _moveCnt);
    
    if (_useAdmob && _moveCnt >= _admobInterval) {
        
        if (_admobType == 0) {
            
            if (_adIntGoogle == nil || [_adIntGoogle isReady] == NO || [_adIntGoogle hasBeenUsed] == YES)
                return;
            
            [_adIntGoogle presentFromRootViewController:[[[UIApplication sharedApplication] keyWindow] rootViewController]];
        }
        else {
            
            if (_adIntColony == NO || _adColonyReady == NO || _adIntShowed == YES)
                return;
            
            _adIntShowed = YES;
            _adColonyReady = NO;
            [AdColony playVideoAdForZone:@"vzcd60dd581caf450788" withDelegate:self];
        }
    }
}

- (void) createAndLoadInterstitial {
    
    if (_useAdmob == NO) {
        
        _adIntGoogle = nil;
        _adIntColony = NO;
        return;
    }
    
    if (_adIntShowed == NO)
        return;
    
    _adIntGoogle = nil;
//    _adIntColony = NO;
    
    if (_admobType == 0) {
        
        _adIntGoogle = [[GADInterstitial alloc] initWithAdUnitID:@"ca-app-pub-6719410133925531/4833263605"];
        _adIntGoogle.delegate = self;
        _adIntShowed = NO;
        [_adIntGoogle loadRequest:[GADRequest request]];
        
        NSLog(@"Request Google Ad Interstitial");
    }
    else {
        
        if (_adIntColony == NO) {
            
            [AdColony configureWithAppID:@"app8be003f9e0b3459a9b"
                                 zoneIDs:@[@"vzcd60dd581caf450788"]
                                delegate:self
                                 logging:YES];
            _adIntColony = YES;
            
            NSLog(@"AdColony Configured Interstitial");
        }
    }
}

// google ad interstitial delegate
- (void) interstitialDidReceiveAd:(GADInterstitial *)ad {
    
    NSLog(@"Google Ad Request success");
}

- (void) interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error {
    
    [self createAndLoadInterstitial];
    NSLog(@"Google Ad Request failed");
}

- (void) interstitialDidDismissScreen:(GADInterstitial *)interstitial {
    
    _moveCnt = 0;
    _adIntShowed = YES;
    
    [self createAndLoadInterstitial];
}

// adcolony interstitial delegate
- (void) onAdColonyAdAttemptFinished:(BOOL)shown inZone:(NSString *)zoneID {
    
    _moveCnt = 0;
    
    [self createAndLoadInterstitial];
}

- (void) onAdColonyAdAvailabilityChange:(BOOL)available inZone:(NSString *)zoneID {
    
    NSLog(@"AdColony State changed to %@", available ? @"available" : @"unavailable");
    
    if (available) {
        
        _adIntShowed = NO;
        _adColonyReady = YES;
    }
    else {
        
        _adColonyReady = NO;
    }
}

@end
