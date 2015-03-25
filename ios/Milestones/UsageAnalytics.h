//
//  UsageAnalytics.h
//  EssentialTips
//
//  Created by Nathan  Pahucki on 6/21/14.
//  Copyright (c) 2015 InfantIQ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UsageAnalytics : NSObject

+ (void)initializeAnalytics:(NSDictionary *)launchOptions;

+ (void)identify:(ParentUser *)user;

+ (void)trackError:(NSError *)error forOperationNamed:(NSString *)operation;

+ (void)trackError:(NSError *)error forOperationNamed:(NSString *)operation andAdditionalProperties:(NSDictionary *)props;

+ (void)trackUserSignup:(ParentUser *)user usingMethod:(NSString *)method;

+ (void)trackUserSignupError:(NSError *)error usingMethod:(NSString *)method;

+ (void)trackUserLinkedWithFacebook:(ParentUser *)user forPublish:(BOOL)publish withError:(NSError *)error;

+ (void)trackUserSignout:(ParentUser *)user;

+ (void)trackAppBecameActive;

+ (void)trackCreateBaby:(Baby *)baby;

+ (void)trackTipShared:(Tip *)achievement sharingMedium:(NSString*) medium;

+ (void)trackAdClicked:(NSString *)adIdentifier;

+ (void)trackTutorialManuallyTaken;

+ (void)trackAppInstalled;

+ (void)trackSignupTrigger:(NSString *)string withChoice:(BOOL)choice;

+ (void)trackClickedToViewOtherAppInAppStore:(NSString *)appName;

+ (void)trackToldFriend;
@end
