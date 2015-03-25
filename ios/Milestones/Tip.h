//
//  Tip.h
//  Milestones
//
//  Created by Nathan  Pahucki on 5/28/14.
//  Copyright (c) 2015 InfantIQ. All rights reserved.
//

typedef enum _TipType : NSUInteger {
    TipTypeAll = 0,
    TipTypeNormal = 1,
    TipTypeGame

} TipType;


@interface Tip : PFObject <PFSubclassing>

+ (NSString *)parseClassName;

@property NSString *title;
@property NSString *shortDescription;
@property(readonly) NSString *titleForCurrentBaby;
@property(readonly) NSString *shortDescriptionForCurrentBaby;
@property TipType tipType;
@property NSString *url;
@property NSNumber *rangeHigh;
@property NSNumber *rangeLow;
@property(readonly) NSString *humanReadableRange;


- (NSString *)titleForBaby:(Baby *)baby;

@end
