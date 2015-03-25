//
//  NSDate+HumanizedTime.h
//  EssentialTips
//
//  Created by Nathan  Pahucki on 6/19/14.
//  Copyright (c) 2015 InfantIQ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (HumanizedTime)

- (NSString *)stringWithHumanizedTimeDifference;

- (NSString *)stringWithHumanizedTimeDifference:(BOOL)withSuffix;

@end