//
//  NotificationsViewController.h
//  Milestones
//
//  Created by Nathan  Pahucki on 5/23/14.
//  Copyright (c) 2015 InfantIQ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewControllerWithBabyInfoButton.h"

@interface MainNotificationsViewController : ViewControllerWithBabyInfoButton
@property(weak, nonatomic) IBOutlet UIView *containerView;
@property(weak, nonatomic) IBOutlet UIView *signUpContainerView;

@end
