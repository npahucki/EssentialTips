//
//  UsageAnalytics.m
//  EssentialTips
//
//  Created by Nathan  Pahucki on 6/21/14.
//  Copyright (c) 2015 InfantIQ. All rights reserved.
//

#import <UXCam/UXCam.h>
#import "Heap.h"
#import "NSDate+Utils.h"
#import "AppsFlyerTracker.h"
#import "Mixpanel.h"
#import "NSError+AsDictionary.h"


static id safe(id object) {
    return object ?: [NSNull null];
}

static NSDictionary *safeForFB(NSDictionary *dict) {
    NSMutableDictionary *fbFriendlyDictionary = [[NSMutableDictionary alloc] initWithCapacity:dict.count];
    for (id key in dict.allKeys) {
        NSString *fbKey;
        if ([key isKindOfClass:[NSString class]]) {
            fbKey = [(NSString *) key stringByReplacingOccurrencesOfString:@"." withString:@"_"];
        } else {
            fbKey = key;
        }

        id value = dict[key];
        // Skip null keys.
        if (value != [NSNull null]) {
            fbFriendlyDictionary[fbKey] = value;
        }
    }
    return fbFriendlyDictionary;
}


static BOOL isRelease;

@implementation UsageAnalytics

+ (void)initializeAnalytics:(NSDictionary *)launchOptions {
# if TARGET_IPHONE_SIMULATOR
    isRelease = NO;
#else
    isRelease = YES;
#endif
    NSLog(@"RUNNING IN RELEASE?:%d", isRelease);
    [Heap setAppId:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"DP.HeapAppId"]];
    [Heap changeInterval:30];
    NSString *mixPanelKey = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"DP.MixPanelKey"];
    Mixpanel *mixpanel = [Mixpanel sharedInstanceWithToken:mixPanelKey launchOptions:launchOptions];
    NSString *uxCamKey = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"DP.UXCamKey"];
    [UXCam startApplicationWithKey:uxCamKey];

    if (isRelease) {
        [AppsFlyerTracker sharedTracker].appsFlyerDevKey = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"DP.AppsFlyerDevKey"];
        [AppsFlyerTracker sharedTracker].appleAppID = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"DP.AppleStoreId"];
        [AppsFlyerTracker sharedTracker].isHTTPS = YES;
        [AppsFlyerTracker sharedTracker].customerUserID = mixpanel.distinctId;
        [[AppsFlyerTracker sharedTracker] trackAppLaunch];
    } else {
        [Heap enableVisualizer];
    }
}

+ (void)identify:(ParentUser *)user {
    NSAssert([NSThread isMainThread], @"UsagaeAnalytics.identify called using a thread other than main!");
    if (user) {
        NSAssert(user.objectId != nil, @"Expected user would have objectId set already");
        NSMutableDictionary *props = [[NSMutableDictionary alloc] initWithDictionary:@{
                @"user.id" : safe(user.objectId),
                @"user.anonymous" : user.isLoggedIn ? @"N" : @"Y",
                @"user.fullName" : safe(user.fullName),
                @"user.linkedToFacebook" : user.isLinkedWithFacebook ? @"Y" : @"N",
                @"user.emailVerified" : [user objectForKey:@"emailVerified"] ? @"Y" : @"N",
                @"user.sex" : user.isMale ? @"M" : @"F"
        }];
        // Don't add if null, this causes problems in Heap!
        if (user.email) props[@"email"] = user.email;

        if (isRelease) {
            Mixpanel *mixpanel = [Mixpanel sharedInstance];
            [Heap identify:props];
            [UXCam tagUsersName:user.objectId additionalData:user.email];
            [UXCam addTag:user.isMale ? @"male" : @"female"];
            [UXCam addTag:user.email ? @"anonymous" : @"signedup"];
            [mixpanel identify:mixpanel.distinctId];
            if (user.email) props[@"$email"] = user.email;
            [mixpanel.people set:props];
            [mixpanel.people setOnce:@{@"createdAt" : [NSDate date]}];
        } else {
            NSLog(@"[USAGE ANALYTICS]: Identify - %@", props);
        }
    }
}

+ (void)trackError:(NSError *)error forOperationNamed:(NSString *)operation {
    [self trackError:error forOperationNamed:operation andAdditionalProperties:nil];
}

+ (void)trackError:(NSError *)error forOperationNamed:(NSString *)operation andAdditionalProperties:(NSDictionary *)props {
    NSMutableDictionary *combinedAttributes = [error asDictionary];
    if (props) [combinedAttributes addEntriesFromDictionary:props];
    combinedAttributes[@"operation"] = operation;
    combinedAttributes[@"timestamp"] = [[NSDate date] asISO8601String];

    if (isRelease) {
        [Heap track:[NSString stringWithFormat:@"Error"] withProperties:combinedAttributes];
        [[Mixpanel sharedInstance] track:@"Error" properties:combinedAttributes];
    } else {
        NSLog(@"[USAGE ANALYTICS]: trackError - Error Properties:%@", combinedAttributes);
    }
}


+ (void)trackUserSignup:(ParentUser *)user usingMethod:(NSString *)method {
    // We want to track the number of milestones.
    if (Baby.currentBaby) {
        if (isRelease) {
            NSDictionary *props = @{
                    @"user.id" : safe(user.objectId),
                    @"method" : safe(method),
            };
            [Heap track:@"userSignedUp" withProperties:props];
            [[Mixpanel sharedInstance] track:@"userSignup" properties:props];
            [[AppsFlyerTracker sharedTracker] trackEvent:@"userSignedUp" withValue:nil];
            [FBAppEvents logEvent:FBAppEventNameCompletedRegistration parameters:safeForFB(props)];
        } else {
            NSLog(@"[USAGE ANALYTICS]: trackUserSignup - User:%@ Method:%@", user, method);
        }
    } else {
        if (isRelease) {
            NSDictionary *props = @{
                    @"user.id" : safe(user.objectId),
                    @"method" : safe(method)
            };
            [Heap track:@"userSignedUp" withProperties:props];
            [[AppsFlyerTracker sharedTracker] trackEvent:@"userSignedUp" withValue:@"0"];
            [FBAppEvents logEvent:FBAppEventNameCompletedRegistration parameters:safeForFB(props)];
            [[Mixpanel sharedInstance] track:@"userSignup" properties:props];
        } else {
            NSLog(@"[USAGE ANALYTICS]: trackUserSignup - User:%@ Method:%@", user, method);
        }
    }
}

+ (void)trackUserSignupError:(NSError *)error usingMethod:(NSString *)method {
    [self trackError:error forOperationNamed:@"userSignup" andAdditionalProperties:@{@"method" : method}];
}

+ (void)trackUserLinkedWithFacebook:(ParentUser *)user forPublish:(BOOL)publish withError:(NSError *)error {
    NSDictionary *props = @{@"user.id" : safe(user.objectId),
            @"forPublish" : publish ? @"Y" : @"N",
    };

    if (error) {
        [self trackError:error forOperationNamed:@"userLinkedWithFacebook" andAdditionalProperties:props];
    } else {
        if (isRelease) {
            [Heap track:@"userLinkedWithFacebook" withProperties:props];
            [[Mixpanel sharedInstance] track:@"userLinkedWithFacebook" properties:props];
            [FBAppEvents logEvent:@"userLinkedWithFacebook" parameters:safeForFB(props)];
            [[AppsFlyerTracker sharedTracker] trackEvent:@"userLinkedWithFacebook" withValue:@""];
        } else {
            NSLog(@"[USAGE ANALYTICS]: trackUserLinkedWithFacebook - User:%@ Publish:%d", user, publish);
        }
    }
}

+ (void)trackUserSignout:(ParentUser *)user {
    if (isRelease) {
        [Heap track:@"userSignedOut" withProperties:@{@"user.id" : safe(user.objectId)}];
        [[Mixpanel sharedInstance] track:@"userSignedOut" properties:@{@"user.id" : safe(user.objectId)}];
        [FBAppEvents logEvent:@"userSignedOut" parameters:@{@"user_id" : safe(user.objectId)}];
        [[AppsFlyerTracker sharedTracker] trackEvent:@"userSignedOut" withValue:@""];
    } else {
        NSLog(@"[USAGE ANALYTICS]: trackUserSignout - User:%@", user);
    }
}

+ (void)trackAppInstalled {
    if (isRelease) {
        [Heap track:@"installApp"];
        [[Mixpanel sharedInstance] track:@"installApp"];
    } else {
        NSLog(@"[USAGE ANALYTICS]: trackAppInstalled");
    }
}


+ (void)trackAppBecameActive {
    if (isRelease) {
        [FBAppEvents activateApp];
        [Heap track:@"activateApp"];
        [[Mixpanel sharedInstance] track:@"activateApp"];
        [[Mixpanel sharedInstance].people increment:@"timesAppActivated" by:@(1)];
        [[AppsFlyerTracker sharedTracker] trackEvent:@"activateApp" withValue:@""];
    } else {
        NSLog(@"[USAGE ANALYTICS]: trackAppBecameActive");
    }
}

+ (void)trackCreateBaby:(Baby *)baby {

    if (isRelease) {
        NSDictionary *props = @{
                @"baby.id" : baby.objectId,
                @"baby.name" : safe(baby.name),
                @"baby.daysSinceBirth" : @(baby.daysSinceBirth)
        };
        [Heap track:@"babyCreated" withProperties:props];
        [[Mixpanel sharedInstance] track:@"babyCreated" properties:props];
        [FBAppEvents logEvent:@"babyCreated" parameters:safeForFB(props)];
        [[AppsFlyerTracker sharedTracker] trackEvent:@"babyCreated" withValue:props.description];

        // Add baby properties
        [[Mixpanel sharedInstance].people set:props];
        [Heap identify:props];
    } else {
        NSLog(@"[USAGE ANALYTICS]: trackCreateBaby - Baby:%@", baby);
    }
}


+ (void)trackTipShared:(Tip *)tip sharingMedium:(NSString *)medium {
    medium = [medium stringByReplacingOccurrencesOfString:@"com.apple.UIKit.activity." withString:@""];
    NSDictionary *props = @{
            @"tip.title" : safe(tip.title),
            @"tip.id" : safe(tip.objectId),
            @"tip.type" : tip.tipType == TipTypeGame ? @"game" : @"normal"
    };

    if (isRelease) {
        [Heap track:@"tipShared" withProperties:props];
        [[Mixpanel sharedInstance] track:@"tipShared" properties:props];
        [[Mixpanel sharedInstance].people increment:@"tipsShared" by:@(1)];
        [FBAppEvents logEvent:@"tipShared" parameters:safeForFB(props)];
    } else {
        NSLog(@"[USAGE ANALYTICS]: trackTipShared via %@: %@", medium, props);
    }

}


+ (void)trackAdClicked:(NSString *)adIdentifier {
    if (isRelease) {
        [Heap track:@"adClicked" withProperties:@{@"adIdentifier" : adIdentifier}];
        [[Mixpanel sharedInstance] track:@"adClicked" properties:@{@"adIdentifier" : adIdentifier}];
        [[Mixpanel sharedInstance].people increment:@"adsClicked" by:@(1)];
        [[AppsFlyerTracker sharedTracker] trackEvent:@"adIdentifier" withValue:adIdentifier];
        [FBAppEvents logEvent:@"adClicked" parameters:@{@"adIdentifier" : adIdentifier}];
    } else {
        NSLog(@"[USAGE ANALYTICS]: trackAdClick - AdId:%@", adIdentifier);
    }
}

+ (void)trackTutorialManuallyTaken {
    if (isRelease) {
        [Heap track:@"tutotialManuallyTaken"];
        [[Mixpanel sharedInstance] track:@"tutotialManuallyTaken"];
        [[Mixpanel sharedInstance].people set:@"tutotialManuallyTaken" to:@(YES)];
        [FBAppEvents logEvent:FBAppEventNameCompletedTutorial];
    } else {
        NSLog(@"[USAGE ANALYTICS]: tutotialManuallyTaken");
    }
}

+ (void)trackSignupTrigger:(NSString *)trigger withChoice:(BOOL)choice {
    if (isRelease) {
        NSDictionary *properties = @ {
                @"trigger" : trigger,
                @"choice" : @(choice)
        };

        [Heap track:@"signUpDecision" withProperties:properties];
        [[Mixpanel sharedInstance] track:@"signUpDecision" properties:properties];
    } else {
        NSLog(@"[USAGE ANALYTICS]: signUpDecision - trigger:%@, decision:%d", trigger, choice);
    }
}

+ (void)trackClickedToViewOtherAppInAppStore:(NSString *)appName {
    if (isRelease) {
        [Heap track:@"clickedToViewOtherAppInAppStore" withProperties:@{@"app" : appName}];
        [[Mixpanel sharedInstance] track:@"clickedToViewOtherAppInAppStore" properties:@{@"app" : appName}];
    } else {
        NSLog(@"[USAGE ANALYTICS]: clickedToViewOtherAppInAppStore - app:%@", appName);
    }
}

+ (void)trackToldFriend {
    if (isRelease) {
        [Heap track:@"toldFriend"];
        [[Mixpanel sharedInstance] track:@"toldFriend"];
    } else {
        NSLog(@"[USAGE ANALYTICS]: toldFriend");
    }

}
@end
