//
//  RequestService.m
//  SmoothPay2.0
//
//  Created by Alex on 11/12/15.
//  Copyright (c) 2015 BCL. All rights reserved.
//

#import "RequestService.h"
#import "CommonUtil.h"
#import "AppSetting.h"
#import "LocationUtil.h"
#import "RequestServiceDefines.h"
#import "NSString+Utilities.h"
#import "RD_Result.h"
#import "RD_QuoteList.h"
#import "RD_Rate.h"
#import "RD_Admob.h"

@implementation RequestService

+ (instancetype) sharedInstance {
    
    static RequestService * instance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        instance = [[RequestService alloc] init];
    });
    
    return instance;
}

+ (void) requestList:(NSInteger)category
                page:(NSInteger)page
                size:(NSInteger)size
              userId:(NSString *)userId
        respondBlock:(RequestRespondBlock)respondBlock
{
    
    RequestService * service = [RequestService sharedInstance];
    NSDictionary * params = @{ @"page" : [NSString stringWithFormat:@"%d", (int) page],
                               @"size" : [NSString stringWithFormat:@"%d", (int) size],
                               @"category" : [NSString stringWithFormat:@"%d", (int) category],
                               @"user_id" : userId };
    
    [service sendPostRequest:kApiRequestList params:params respondBlock:^(id respond, NSError *error) {
        
        RD_QuoteList * result = [[RD_QuoteList alloc] initFromJson:respond];
        
        respondBlock(result, error);
    }];
}

+ (void) requestLike:(NSString *)userId
             quoteId:(NSString *)quoteId
        respondBlock:(RequestRespondBlock)respondBlock
{
    
    RequestService * service = [RequestService sharedInstance];
    NSDictionary * params = @{ @"quotes_id" : quoteId,
                               @"user_id" : userId };
    
    [service sendPostRequest:kApiRequestLike params:params respondBlock:^(id respond, NSError *error) {
        
        RD_Rate * result = [[RD_Rate alloc] initFromJson:respond];
        
        respondBlock(result, error);
    }];
}

+ (void) requestDislike:(NSString *)userId
                quoteId:(NSString *)quoteId
           respondBlock:(RequestRespondBlock)respondBlock
{
    
    RequestService * service = [RequestService sharedInstance];
    NSDictionary * params = @{ @"quotes_id" : quoteId,
                               @"user_id" : userId };
    
    [service sendPostRequest:kApiRequestDislike params:params respondBlock:^(id respond, NSError *error) {
        
        RD_Rate * result = [[RD_Rate alloc] initFromJson:respond];
        
        respondBlock(result, error);
    }];
}

+ (void) requestAdmob:(RequestRespondBlock)respondBlock
{
    
    RequestService * service = [RequestService sharedInstance];
    
    [service sendPostRequest:kApiRequestAdmob params:nil respondBlock:^(id respond, NSError *error) {
        
        RD_Admob * result = [[RD_Admob alloc] initFromJson:respond];
        
        respondBlock(result, error);
    }];
}

+ (void) requestRegister:(NSString *)userId
                   iosId:(NSString *)iosId
            respondBlock:(RequestRespondBlock)respondBlock
{
    
    RequestService * service = [RequestService sharedInstance];
    NSDictionary * params = @{ @"ios_id" : iosId,
                               @"user_id" : userId };
    
    [service sendPostRequest:kApiRequestRegister params:params respondBlock:^(id respond, NSError *error) {
        
        RD_Result * result = [[RD_Result alloc] initFromJson:respond];
        
        respondBlock(result, error);
    }];
}

@end
