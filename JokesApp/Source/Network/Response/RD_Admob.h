//
//  RD_Admob.h
//  JokesApp
//
//  Created by Michael Lee on 2/5/16.
//  Copyright © 2016 Michael Lee. All rights reserved.
//

#import "RD_Result.h"

@interface RD_Admob : RD_Result

@property (nonatomic, assign) BOOL      useAdmob;
@property (nonatomic, assign) BOOL      admobType;
@property (nonatomic, assign) NSInteger admobInterval;

@end
