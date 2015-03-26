//
//  MainMilestonesViewController.m
//  EssentialTips
//
//  Created by Nathan  Pahucki on 3/26/15.
//  Copyright (c) 2015 Infant IQ. All rights reserved.
//

#import "MainMilestonesViewController.h"

@interface MainMilestonesViewController ()

@end

@implementation MainMilestonesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.textLabel.font = [UIFont fontForAppWithType:Medium andSize:32.0];
    self.textLabel.textColor = [UIColor appGreyTextColor];
    self.textLabel.text = [NSString stringWithFormat:self.textLabel.text, [Baby currentBaby].name, [Baby currentBaby].isMale ? @"his" : @"her"];
    self.getTheAppButton.titleLabel.font = [UIFont fontForAppWithType:Book andSize:23.0];
    [self.getTheAppButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.view.layer removeAllAnimations];
    self.arrowBottomContraint.constant = 32;
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:3.0 delay:0.0 usingSpringWithDamping:0.1 initialSpringVelocity:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.arrowBottomContraint.constant = 8;
        [self.view layoutIfNeeded];
    }                completion:NULL];
}

- (IBAction)didClickGetAppNowButton:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms://itunes.apple.com/us/app/dataparenting-baby-milestones/id905124835?mt=8"]];
    [UsageAnalytics trackClickedToViewOtherAppInAppStore:@"DataParenting"];
}

@end
