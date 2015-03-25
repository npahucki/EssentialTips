//
//  EnterScreenNameViewController.h
//  Milestones
//
//  Created by Nathan  Pahucki on 1/27/14.
//  Copyright (c) 2015 InfantIQ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BabyInfoViewController.h"
#import "UIViewControllerWithHUDProgress.h"

@interface EnterScreenNameViewController : OnboardingStepViewController <UITextFieldDelegate, CMPopTipViewDelegate>

@property(strong, nonatomic) IBOutlet UIButton *maleButton;
@property(strong, nonatomic) IBOutlet UIButton *femaleButton;
@property(strong, nonatomic) IBOutlet UILabel *maleLabel;
@property(strong, nonatomic) IBOutlet UILabel *femaleLabel;
@property(weak, nonatomic) IBOutlet UIButton *acceptTACButton;
@property(weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property(weak, nonatomic) IBOutlet UIButton *acceptTACLabelButton;
@property(weak, nonatomic) IBOutlet UIButton *supportScienceButton;
@property (weak, nonatomic) IBOutlet UILabel *iAmLabel;


@end
