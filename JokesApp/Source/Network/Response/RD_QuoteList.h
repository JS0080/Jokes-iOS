//
//  RD_QuoteList.h
//  JokesApp
//
//  Created by Michael Lee on 1/29/16.
//  Copyright © 2016 Michael Lee. All rights reserved.
//

#import "RD_Result.h"
#import "MWPhoto.h"

@interface RD_Quote : RD_Base

@property (nonatomic, retain) NSString *    quoteId;
@property (nonatomic, retain) NSString *    quoteUrl;
@property (nonatomic, assign) NSInteger     rate;

@end

@interface RD_QuoteList : RD_Result

@property (nonatomic, retain) NSArray *     quoteList;
@property (nonatomic, assign) NSInteger     page;
@property (nonatomic, assign) NSInteger     size;
@property (nonatomic, assign) NSInteger     totalCount;
@property (nonatomic, assign) NSInteger     totalPage;

- (NSUInteger) quoteCount;
- (NSURL *)    quoteUrlAt:(NSUInteger)index;
- (RD_Quote *) quoteAt:(NSUInteger)index;

- (void) appendQuoteList:(RD_QuoteList *)list;

@end
