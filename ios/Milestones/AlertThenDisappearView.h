//
//  AlertThenDisappearView.h
//  EssentialTips
//
//  Created by Nathan  Pahucki on 7/1/14.
//  Copyright (c) 2015 InfantIQ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlertThenDisappearView : UIView

@property(weak, nonatomic) IBOutlet UIImageView *imageView;
@property(weak, nonatomic) IBOutlet UILabel *titleLabel;


+ (AlertThenDisappearView *)instanceForViewController:(UIViewController *)controller;

+ (AlertThenDisappearView *)instanceForView:(UIView *)view;

- (void)show;

- (void)showWithDelay:(NSTimeInterval)delay;


@end
