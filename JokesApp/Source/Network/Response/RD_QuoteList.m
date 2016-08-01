//
//  RD_QuoteList.m
//  JokesApp
//
//  Created by Michael Lee on 1/29/16.
//  Copyright © 2016 Michael Lee. All rights reserved.
//

#import "RD_QuoteList.h"
#import "RequestServiceDefines.h"

@implementation RD_Quote

- (BOOL) fromJson:(id)json {
    
    if (json == nil) json = [NSDictionary dictionary];
    
    self.quoteId  = [json optString:@"id" defaultValue:@""];
    self.quoteUrl = [json optString:@"url" defaultValue:@""];
    self.rate     = [json optInt:@"rv" defaultValue:0];
    
    return YES;
}

@end

@implementation RD_QuoteList

- (BOOL) fromJson:(id)json {
    
    if (![super fromJson:json])
        return NO;
    
    id jsonRes = [json getJSONObject:@"response"];
    
    self.quoteList  = [self arrayFromJson:jsonRes key:@"list" rdClass:[RD_Quote class]];
    self.page       = [jsonRes optInt:@"page" defaultValue:0];
    self.size       = [jsonRes optInt:@"size" defaultValue:0];
    self.totalCount = [jsonRes optInt:@"total_num_rows" defaultValue:0];
    self.totalPage  = [jsonRes optInt:@"total_page" defaultValue:0];
    
    return YES;
}

- (NSUInteger) quoteCount {
    
    return self.quoteList.count;
}

- (NSURL *) quoteUrlAt:(NSUInteger)index {
    
    RD_Quote * quote = [self.quoteList objectAtIndex:index];
    NSString * strUrl;
    
    strUrl = [NSString stringWithFormat:@"%@%@", kWebJokesAppImageUrl, quote.quoteUrl];
    
    return [NSURL URLWithString:strUrl];
}

- (RD_Quote *) quoteAt:(NSUInteger)index {
    
    return [self.quoteList objectAtIndex:index];
}

- (void) appendQuoteList:(RD_QuoteList *)list {
    
    self.quoteList = [self.quoteList arrayByAddingObjectsFromArray:list.quoteList];
}

@end
