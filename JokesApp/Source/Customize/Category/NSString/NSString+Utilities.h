//
//  NSString+Utilities.h
//  SmoothPay2.0
//
//  Created by Alex on 11/12/15.
//  Copyright (c) 2015 BCL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Utilities)

- (BOOL) isEmpty;
- (BOOL) isTrimEmpty;

- (float) parseFloatAt:(int)pos len:(int)len;
- (int) parseAPAt:(int)pos len:(int)len;
- (float) parsePrice;

@end
