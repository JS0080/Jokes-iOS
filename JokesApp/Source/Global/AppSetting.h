//
//  AppSetting.h
//  SmoothPay2.0
//
//  Created by Alex on 11/12/15.
//  Copyright (c) 2015 BCL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppSettingBase.h"
#import "RD_QuoteList.h"

@interface AppSetting : AppSettingBase

@property (nonatomic, assign) BOOL              firstLaunch;
@property (nonatomic, assign) BOOL              registered;
@property (nonatomic, retain) NSString *        userId;
@property (nonatomic, retain) NSString *        pushId;
@property (nonatomic, retain) NSDate *          refreshTime;

@property (nonatomic, assign) BOOL              useAdmob;
@property (nonatomic, assign) NSInteger         admobType;
@property (nonatomic, assign) NSInteger         admobInterval;

@property (nonatomic, assign) NSInteger         moveCnt;

@property (nonatomic, retain) RD_QuoteList *    listHot;
@property (nonatomic, retain) RD_QuoteList *    listNew;
@property (nonatomic, retain) RD_QuoteList *    listTop;
@property (nonatomic, retain) RD_QuoteList *    listFav;

+ (AppSetting *) sharedInstance;

- (void) setRefreshing:(BOOL)refreshing category:(NSInteger)category;
- (BOOL) refreshing:(NSInteger)category;

- (void) setQuoteList:(RD_QuoteList *)list category:(NSInteger)category;
- (RD_QuoteList *) quoteList:(NSInteger)category;

- (void) increaseMoveCnt;
- (void) createAndLoadInterstitial;

@end

static inline AppSetting * appSetting() {
    
    return [AppSetting sharedInstance];
}
