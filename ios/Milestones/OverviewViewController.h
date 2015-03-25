//
//  SettingsViewController.h
//  Milestones
//
//  Created by Nathan  Pahucki on 4/1/14.
//  Copyright (c) 2015 InfantIQ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ParseUI/ParseUI.h>


@interface OverviewViewController : UIViewController
@property(strong, nonatomic) IBOutlet UILabel *babyNameLabel;
@property(strong, nonatomic) IBOutlet UILabel *ageLabel;
@property(strong, nonatomic) IBOutlet PFImageView *babyAvatar;
@property(weak, nonatomic) IBOutlet UIButton *logOutOrSignUpButton;
@property(weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property(weak, nonatomic) IBOutlet UILabel *numberOfMilestonesLabel;
@end


