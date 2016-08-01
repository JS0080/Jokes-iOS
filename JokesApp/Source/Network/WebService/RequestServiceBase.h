//
//  RequestServiceBase.h
//  SmoothPay2.0
//
//  Created by Alex on 11/12/15.
//  Copyright (c) 2015 BCL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebSessionManager.h"

@interface RequestServiceBase : NSObject

- (void) sendPostRequest:(NSString *)request params:(NSDictionary *)params respondBlock:(WebRespondBlock)respondBlock;
- (void) sendGetRequest:(NSString *)request params:(NSDictionary *)params respondBlock:(WebRespondBlock)respondBlock;
- (void) sendRequest:(NSString *)request params:(NSDictionary *)params type:(WebRequestType)type respondBlock:(WebRespondBlock)respondBlock;

@end
