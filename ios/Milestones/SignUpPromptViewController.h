//
//  TipsSignUpPromptViewController.h
//  Milestones
//
//  Created by Nathan  Pahucki on 5/23/14.
//  Copyright (c) 2015 InfantIQ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignUpPromptViewController : UIViewController
@property(weak, nonatomic) IBOutlet UILabel *promptTextLabel;
@property (weak, nonatomic) IBOutlet UIButton *signupNowButton;
@property(weak, nonatomic) IBOutlet NSLayoutConstraint *arrowImageViewBottomConstraint;
@property(weak, nonatomic) IBOutlet UILabel *auxPromptTextLabel;

@end
