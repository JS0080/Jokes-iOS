//
//  WebSessionManager.m
//  SmoothPay2.0
//
//  Created by Alex on 11/12/15.
//  Copyright (c) 2015 BCL. All rights reserved.
//

#import "WebSessionManager.h"
#import "AFHTTPSessionManager.h"

NSInteger const WebRequestServerNoBase = 0;

@interface WebSessionManager () {
    
    AFHTTPSessionManager *      _sessionManager;
    NSMutableDictionary *       _webServers;
}

@end

@implementation WebSessionManager

#pragma mark - initialization

+ (instancetype) sharedInstance {
    
    static WebSessionManager * _instance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        _instance = [[WebSessionManager alloc] init];
    });
    
    return _instance;
}

- (instancetype) init {
    
    self = [super init];
    
    if (self) {
        
        [self setup];
    }
    
    return self;
}

- (void) setup {
    
    _webServers = [NSMutableDictionary dictionary];
    
    _sessionManager = [[AFHTTPSessionManager alloc] init];
    _sessionManager.responseSerializer.acceptableContentTypes = [_sessionManager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
}

#pragma mark - Request

- (BOOL)sendRequestToServer:(NSInteger)server
                       type:(WebRequestType)type
                       path:(NSString *)path
                     params:(NSDictionary *)params
               respondBlock:(WebRespondBlock)respondBlock {
    
    NSString * baseUrl;
    NSString * url = path;
    NSString * key;
    
    key = [NSString stringWithFormat:@"server_%ld", (long)server];
    baseUrl = [_webServers valueForKey:key];
    
    if (baseUrl) {
        
        if (![path hasPrefix:baseUrl]) {
            
            if ([path hasPrefix:@"/"])
                path = [path stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
            
            url = [NSString stringWithFormat:@"%@%@", baseUrl, path];
        }
    }
    
    NSURLSessionDataTask * task;
    
    void (^successBlock) (NSURLSessionDataTask * __unused task, id result) = ^(NSURLSessionDataTask * __unused task, id result) {
        
        if (respondBlock)
            respondBlock(result, nil);
    };
    
    void (^failedBlock) (NSURLSessionDataTask * __unused task, NSError * error) = ^(NSURLSessionDataTask * __unused task, NSError * error) {
        
        if (respondBlock)
            respondBlock(nil, error);
    };
    
    switch (type) {
            
        case WebRequestTypeGet:
            
            task = [_sessionManager GET:url parameters:params progress:nil success:successBlock failure:failedBlock];
            break;
            
        case WebRequestTypePost:
            
            task = [_sessionManager POST:url parameters:params progress:nil success:successBlock failure:failedBlock];
            break;
            
        case WebRequestTypeDelete:
            
            task = [_sessionManager DELETE:url parameters:params success:successBlock failure:failedBlock];
            break;
            
        case WebRequestTypePut:
            
            task = [_sessionManager PUT:url parameters:params success:successBlock failure:failedBlock];
            break;
            
        case WebRequestTypeHead:
            
            task = [_sessionManager HEAD:url parameters:params success:^(NSURLSessionDataTask *task) {
                
                if (respondBlock)
                    respondBlock(nil, nil);
                
            } failure:failedBlock];
            
            break;
    }
    
    [task resume];
    
    return YES;
}

- (BOOL) sendRequestWithUrl:(NSString *)strUrl type:(WebRequestType)type params:(NSDictionary *)params respondBlock:(WebRespondBlock)respondBlock {
    
    return [self sendRequestToServer:WebRequestServerNoBase type:type path:strUrl params:params respondBlock:respondBlock];
}

#pragma mark - Register Web Server

- (void) registerWebServer:(NSInteger)serverId serverBaseUrl:(NSString *)serverBaseUrl {
    
    NSString * key = [NSString stringWithFormat:@"server_%ld", (long)serverId];
    
    if ([serverBaseUrl hasSuffix:@"/"])
        [_webServers setValue:serverBaseUrl forKey:key];
    else
        [_webServers setValue:[serverBaseUrl stringByAppendingString:@"/"] forKey:key];
}

@end
