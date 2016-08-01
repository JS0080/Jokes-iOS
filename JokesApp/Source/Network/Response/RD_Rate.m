//
//  RD_Rate.m
//  JokesApp
//
//  Created by Michael Lee on 1/30/16.
//  Copyright © 2016 Michael Lee. All rights reserved.
//

#import "RD_Rate.h"

@implementation RD_Rate

- (BOOL) fromJson:(id)json {
    
    if (![super fromJson:json])
        return NO;
    
    id jsonRes = [json getJSONObject:@"response"];
    
    self.rate = [jsonRes optInt:@"rate" defaultValue:0];
    self.rv   = [jsonRes optInt:@"rv" defaultValue:0];
    
    return YES;
}

@end
