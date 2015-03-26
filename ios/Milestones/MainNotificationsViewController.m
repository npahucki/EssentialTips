//
//  NotificationsViewController.m
//  Milestones
//
//  Created by Nathan  Pahucki on 5/23/14.
//  Copyright (c) 2015 InfantIQ. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import <CMPopTipView/CMPopTipView.h>
#import "MainNotificationsViewController.h"
#import "NotificationTableViewController.h"
#import "NoConnectionAlertView.h"
#import "CMPopTipView+WithStaticInitializer.h"

@interface MainNotificationsViewController ()

@end

@implementation MainNotificationsViewController {
    NotificationTableViewController *_tableController;
    NSInteger _currentBadge;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    // Register here so we can handle these in the background, EVEN if the tab has never been selected
    // since selecting the tab the first time is what triggers viewDidLoad.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnterForeground:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotPushNotification:) name:kDDNotificationPushReceived object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tipAssignmentViewedOrHidden:) name:kDDNotificationTipAssignmentViewedOrHidden object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentBabyChanged) name:kDDNotificationCurrentBabyChanged object:nil];

    _currentBadge = -1;
    return self;
}

- (void)currentBabyChanged {
    [self showToastTipIfNeeded];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [NoConnectionAlertView createInstanceForController:self];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    BOOL isLoggedIn = [ParentUser currentUser].isLoggedIn;  // Note may be linked with Facebook, but still not have Email address.
    self.containerView.hidden = !isLoggedIn;
    self.signUpContainerView.hidden = isLoggedIn;
    [self showToastTipIfNeeded];
}

- (void)showToastTipIfNeeded {
    if([Baby currentBaby] && ![ParentUser currentUser].shownTutorialPrompt) {
        // Toggle popTipView when a standard UIButton is pressed
        NSString *msg = [NSString stringWithFormat:@"Every few days, you'll receive a new tip or game idea based on %@'s age.", [Baby currentBaby].name];
        self.tipView = [CMPopTipView instanceWithApplicationLookAndFeelAndMessage:msg];
        self.tipView.delegate = self;
        self.tipView.maxWidth = self.view.frame.size.width - 30;

        // HACK ALERT: There is no way to find the view for the tab bar item, and seemingly no way to
        // map the tabBarItem back to the view...so as long as we don't add anything after the
        // Share tab, this will keep working. Things can be added before with no problem.
        UIView *tabBarView = nil;
        for (UIView *view in self.tabBarController.tabBar.subviews) {
            if ([view isKindOfClass:[UIControl class]]) {
                tabBarView = view;
                // We want the first one....NOTE: This wil break if we move tips to anything other than the first tab!!
                break;
            }
        }
        [self.tipView presentPointingAtView:tabBarView inView:self.tabBarController.view animated:YES];
        [ParentUser currentUser].shownTutorialPrompt = YES;
    }
}

- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView {
    self.tipView = nil;
    [_tableController loadObjects]; // quick hack to show any tips if push notifications turned off
}


- (void)ensureInitialBadgeValueSet:(BOOL)force playSoundIfUpdated:(BOOL)useSound {
    if ((_currentBadge == -1 || force) && Baby.currentBaby) {
        [PFCloud callFunctionInBackground:@"tipBadgeCount"
                           withParameters:@{@"babyId" : Baby.currentBaby.objectId,
                                   @"appVersion" : NSBundle.mainBundle.infoDictionary[@"CFBundleShortVersionString"],
                                   @"showHiddenTips" : @(ParentUser.currentUser.showHiddenTips)}
                                    block:^(NSDictionary *objects, NSError *error) {
                                        NSNumber *badge = objects[@"badge"];
                                        if (badge) {
                                            if (_currentBadge != badge.integerValue) {
                                                _currentBadge = badge.integerValue;
                                                [self updateBadgeFromCurrent];
                                                if (useSound) {
                                                    AudioServicesPlaySystemSound(1003);
                                                }
                                            }

                                        }
                                    }];
    }
}


- (void)tipAssignmentViewedOrHidden:(NSNotification *)notice {
    BabyAssignedTip *tipAssignment = notice.object;
    if (_currentBadge == -1) {
        [self ensureInitialBadgeValueSet:NO playSoundIfUpdated:NO];
    } else {
        // Don't decrement the count, if a previously viewed tip has been hidden
        if (!(tipAssignment.isHidden && tipAssignment.viewedOn)) {
            if (_currentBadge > 0) {
                _currentBadge--;
            }
            [self updateBadgeFromCurrent];
        }
    }
}

- (void)gotPushNotification:(NSNotification *)notice {
    // First check if it is a tipsNotification, ignore if not.
    if ([kDDPushNotificationTypeTip isEqualToString:notice.userInfo[kDDPushNotificationField_CData][kDDPushNotificationField_Type]]) {
        if (((NSNumber *) notice.userInfo[kDDPushNotificationField_OpenedFromBackground]).boolValue) {
            // Make this the currently selected tab
            self.navigationController.tabBarController.selectedViewController = self.navigationController;
        }
        [_tableController loadObjects];
        [self ensureInitialBadgeValueSet:YES playSoundIfUpdated:YES];
    }
}

- (void)updateBadgeFromCurrent {
    self.navigationController.tabBarItem.badgeValue = _currentBadge > 0 ? @(_currentBadge).stringValue : nil;
}

- (void)appEnterForeground:(NSNotification *)notice {
    [_tableController loadObjects];
    [self ensureInitialBadgeValueSet:YES playSoundIfUpdated:NO];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // The only segue is the embed
    if ([segue.destinationViewController isKindOfClass:[NotificationTableViewController class]]) {
        _tableController = (NotificationTableViewController *) segue.destinationViewController;
    }
}

- (void)babyUpdated:(NSNotification *)notification {
    [super babyUpdated:notification];
    [self ensureInitialBadgeValueSet:YES playSoundIfUpdated:NO];
}



@end
