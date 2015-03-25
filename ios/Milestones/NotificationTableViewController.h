//
//  NotificationTableViewController.h
//  Milestones
//
//  Created by Nathan  Pahucki on 5/28/14.
//  Copyright (c) 2015 InfantIQ. All rights reserved.
//

#import "SWTableViewCell.h"

@interface NotificationTableViewCell : SWTableViewCell

- (void)setBabyAssignedTip:(BabyAssignedTip *)tipAssignment;

@end

@interface NotificationTableViewController : UITableViewController <SWTableViewCellDelegate, UITableViewDelegate, UITableViewDataSource>

- (void)loadObjects;

@end


