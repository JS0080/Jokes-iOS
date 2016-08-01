//
//  RequestService.h
//  SmoothPay2.0
//
//  Created by Alex on 11/12/15.
//  Copyright (c) 2015 BCL. All rights reserved.
//

#import "RequestServiceBase.h"
#import "RD_Base.h"

typedef void (^RequestRespondBlock) (RD_Base * respond, NSError * error);

@interface RequestService : RequestServiceBase

+ (instancetype) sharedInstance;

+ (void) requestList:(NSInteger)category
                page:(NSInteger)page
                size:(NSInteger)size
              userId:(NSString *)userId
        respondBlock:(RequestRespondBlock)respondBlock;

+ (void) requestLike:(NSString *)userId
             quoteId:(NSString *)quoteId
        respondBlock:(RequestRespondBlock)respondBlock;

+ (void) requestDislike:(NSString *)userId
                quoteId:(NSString *)quoteId
           respondBlock:(RequestRespondBlock)respondBlock;

+ (void) requestAdmob:(RequestRespondBlock)respondBlock;

+ (void) requestRegister:(NSString *)userId
                   iosId:(NSString *)iosId
            respondBlock:(RequestRespondBlock)respondBlock;

@end
