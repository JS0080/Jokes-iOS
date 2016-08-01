//
//  RD_Result.m
//  SmoothPay2.0
//
//  Created by Alex on 11/12/15.
//  Copyright (c) 2015 BCL. All rights reserved.
//

#import "RD_Result.h"

@implementation RD_Result

- (void) setup {
    
    self.message = @"Unknown Error";
    self.result = RDResultErrorUnknown;
}

- (BOOL) fromJson:(id)json {
    
    if (![super fromJson:json])
        return NO;
    
    id  jsonStatus = [json getJSONObject:@"status"];
    int code       = [jsonStatus optInt:@"code" defaultValue:1];
    
    if (code == 0) {
        
        self.result = RDResultSuccess;
    }
    else {
        
        self.result  = RDResultErrorUnknown;
        self.message = [jsonStatus optString:@"message" defaultValue:@""];
    }
    
    return YES;
}

@end
