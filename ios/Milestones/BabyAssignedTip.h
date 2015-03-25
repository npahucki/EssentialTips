//
//  BabyAssignedTip.h
//  Milestones
//
//  Created by Nathan  Pahucki on 5/28/14.
//  Copyright (c) 2015 InfantIQ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BabyAssignedTip : PFObject <PFSubclassing>

+ (NSString *)parseClassName;

@property Baby *baby;
@property Tip *tip;
@property NSDate *assignmentDate;
@property NSDate *viewedOn;
@property BOOL isHidden;

@end
