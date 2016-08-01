//
//  RequestServiceBase.m
//  SmoothPay2.0
//
//  Created by Alex on 11/12/15.
//  Copyright (c) 2015 BCL. All rights reserved.
//

#import "RequestServiceBase.h"
#import "RequestServiceDefines.h"

@implementation RequestServiceBase

- (instancetype) init {
    
    self = [super init];
    if (self) {
        
        [[WebSessionManager sharedInstance] registerWebServer:kWebJokesAppServerNum serverBaseUrl:kWebJokesAppServerUrl];
    }
    return self;
}

- (void) sendPostRequest:(NSString *)request params:(NSDictionary *)params respondBlock:(WebRespondBlock)respondBlock {
    
    [self sendRequest:request params:params type:WebRequestTypePost respondBlock:respondBlock];
}

- (void) sendGetRequest:(NSString *)request params:(NSDictionary *)params respondBlock:(WebRespondBlock)respondBlock {
    
    [self sendRequest:request params:params type:WebRequestTypeGet respondBlock:respondBlock];
}

- (void) sendRequest:(NSString *)request params:(NSDictionary *)params type:(WebRequestType)type respondBlock:(WebRespondBlock)respondBlock {
    
    [[WebSessionManager sharedInstance] sendRequestToServer:kWebJokesAppServerNum type:type path:request params:params respondBlock:respondBlock];
}

- (NSString *) paramsToUrlString:(NSDictionary *)params {
    
    NSMutableString * strUrl = [NSMutableString string];
    
    if (params) {
        
        NSArray * keys = params.allKeys;
        
        for (NSString * key in keys) {
            
            [strUrl appendFormat:@"%@=%@&", key, [[params valueForKey:key] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        }
        
        [strUrl deleteCharactersInRange:NSMakeRange(strUrl.length - 1, 1)];
    }
    
    return strUrl;
}

- (NSString *) createUrlWithBaseUrl:(NSString *)baseUrl path:(NSString *)path params:(NSDictionary *)params {
    
    NSMutableString * strUrl = [NSMutableString string];
    NSString * url = path;
    
    if (baseUrl) {
        
        if (![baseUrl hasSuffix:@"/"])
            baseUrl = [baseUrl stringByAppendingString:@"/"];
        
        if (![path hasPrefix:baseUrl]) {
            
            if ([path hasPrefix:@"/"])
                path = [path stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
            
            url = [NSString stringWithFormat:@"%@%@", baseUrl, path];
        }
    }
    
    [strUrl appendString:url];
    
    if (params) {
        
        [strUrl appendString:@"?"];
        [strUrl appendString:[self paramsToUrlString:params]];
    }
    
    return strUrl;
}

@end
