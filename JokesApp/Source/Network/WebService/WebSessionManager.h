//
//  WebSessionManager.h
//  SmoothPay2.0
//
//  Created by Alex on 11/12/15.
//  Copyright (c) 2015 BCL. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, WebRequestType) {
    
    WebRequestTypeGet = 1,
    WebRequestTypePost,
    WebRequestTypeHead,
    WebRequestTypePut,
    WebRequestTypeDelete
};

typedef void (^WebRespondBlock) (id respond, NSError * error);

extern NSInteger const WebRequestServerNoBase;

@interface WebSessionManager : NSObject

/**
 * Get global shared instance of WebSessionManager
 */
+ (instancetype) sharedInstance;

/**
 * Send request to server
 *
 * @param server - indicate server to send request.
 * @param type - indicate request type. Valid request type is Get, Post, Head, Put or Delete
 * @param path - request url without base url of server
 * @param params - request params
 * @param respondBlock - block of respond
 */
- (BOOL) sendRequestToServer:(NSInteger)server
                        type:(WebRequestType)type
                        path:(NSString *)path
                      params:(NSDictionary *)params
                respondBlock:(WebRespondBlock)respondBlock;

/**
 * Send request to url
 * 
 * @param strUrl - indicate url to send request.
 * @param type - indicate request type. Valid request type is Get, Post, Head, Put and Delete
 * @param params - request params
 * @param respondBlock - block to respond of reuqest
 */
- (BOOL) sendRequestWithUrl:(NSString *)strUrl
                       type:(WebRequestType)type
                     params:(NSDictionary *)params
               respondBlock:(WebRespondBlock)respondBlock;

/**
 * Register server to manager
 *
 * @param serverId - indicate server's identification
 * @param serverBaseUrl - base url of server
 */
- (void) registerWebServer:(NSInteger)serverId serverBaseUrl:(NSString *)serverBaseUrl;

@end
