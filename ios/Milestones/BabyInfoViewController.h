//
//  BabyInfoViewController.h
//  Milestones
//
//  Created by Nathan  Pahucki on 1/21/14.
//  Copyright (c) 2015 InfantIQ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewControllerWithHUDProgress.h"
#import "UIDateField.h"
#import "OnboardingStepViewController.h"


@interface BabyInfoViewController : OnboardingStepViewController <UITextFieldDelegate>



@property(strong, nonatomic) IBOutlet UIDateField *dobTextField;
@property(strong, nonatomic) IBOutlet UIDateField *dueDateTextField;
@property(strong, nonatomic) IBOutlet UITextField *babyName;
@property(strong, nonatomic) IBOutlet UIButton *maleButton;
@property(strong, nonatomic) IBOutlet UIButton *femaleButton;
@property(strong, nonatomic) IBOutlet UIBarButtonItem *nextButton;

@property(strong, nonatomic) IBOutlet UILabel *maleLabel;
@property(strong, nonatomic) IBOutlet UILabel *femaleLabel;
@property(weak, nonatomic) IBOutlet UILabel *dueDateLabel;
@property(weak, nonatomic) IBOutlet UILabel *birthDateLabel;
@property(weak, nonatomic) IBOutlet UILabel *genderLabel;

@end


