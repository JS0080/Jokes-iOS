//
//  RD_Result.h
//  SmoothPay2.0
//
//  Created by Alex on 11/12/15.
//  Copyright (c) 2015 BCL. All rights reserved.
//

#import "RD_Base.h"

typedef NS_ENUM(NSUInteger, RDResultCode) {
    
    RDResultSuccess,
    RDResultErrorEmailExist,
    RDResultErrorEmailInvalid,
    RDResultErrorInput,
    RDResultErrorInvalidCard,
    RDResultErrorFacebook,
    RDResultErrorUnknown,
};

@interface RD_Result : RD_Base

@property (nonatomic, assign) RDResultCode  result;
@property (nonatomic, retain) NSString *    message;

@end
