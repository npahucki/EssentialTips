//
//  OptionalSignUpViewController.h
//  EssentialTips
//
//  Created by Nathan  Pahucki on 10/9/14.
//  Copyright (c) 2015 InfantIQ. All rights reserved.
//

#import "SignUpOrLoginViewController.h"
#import "BabyInfoViewController.h"
#import "UIViewController+MBProgressHUD.h"

@interface OptionalSignUpViewController : OnboardingStepViewController<UITextFieldDelegate>

@property(weak, nonatomic) IBOutlet UITextField *emailTextField;
@property(weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property(weak, nonatomic) IBOutlet UIButton *signupWithFacebookButton;

@end
