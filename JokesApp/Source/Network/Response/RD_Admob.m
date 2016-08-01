//
//  RD_Admob.m
//  JokesApp
//
//  Created by Michael Lee on 2/5/16.
//  Copyright © 2016 Michael Lee. All rights reserved.
//

#import "RD_Admob.h"

@implementation RD_Admob

- (BOOL) fromJson:(id)json {
    
    if (![super fromJson:json])
        return NO;
    
    NSArray * arr = [json optJSONArray:@"response"];
    
    self.useAdmob = NO;
    self.admobType = 8;
    self.admobInterval = 7;
    
    for (int i = 0; i < arr.count; i ++) {
        
        id jsonAd = [arr objectAtIndex:i];
        int freq = [jsonAd optInt:@"frequency" defaultValue:5];
        NSString * strKind = [[jsonAd optString:@"kind" defaultValue:@""] lowercaseString];
        int status = [jsonAd optInt:@"status" defaultValue:0];
        
        if (status == 1) {
            
            if ([strKind isEqualToString:@"google"] || [strKind isEqualToString:@"adcolony"]) {
                
                self.useAdmob = YES;
                self.admobInterval = freq;
                if ([strKind isEqualToString:@"google"])
                    self.admobType = 0;
                else
                    self.admobType = 1;
            }
        }
    }
    
    return YES;
}

@end
