//
//  NotificationDetailViewController.h
//  EssentialTips
//
//  Created by Nathan  Pahucki on 9/3/14.
//  Copyright (c) 2015 InfantIQ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationDetailViewController : UIViewController
@property(weak, nonatomic) IBOutlet UITextView *detailTextView;
@property(strong, nonatomic) BabyAssignedTip *tipAssignment;

@end
