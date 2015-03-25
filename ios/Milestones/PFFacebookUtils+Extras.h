//
//  PFFacebookUtils+PFFacebookUtils_Extras.h
//  Milestones
//
//  Created by Nathan  Pahucki on 6/5/14.
//  Copyright (c) 2015 InfantIQ. All rights reserved.
//

#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>

#define FB_PUBLISH_PERMISSION_ARRAY @[@"publish_actions",@"email",@"public_profile"]

@interface PFFacebookUtils (PFFacebookUtils_Extras)

+ (BOOL)userHasAuthorizedPublishPermissions:(PFUser *)user;

+ (void)ensureHasPublishPermissions:(ParentUser *)user block:(PFBooleanResultBlock)block;

+ (void)populateCurrentUserDetailsFromFacebook:(ParentUser *)user block:(PFBooleanResultBlock)block;

+ (void)showFacebookErrorAlert:(NSError *)error;

@end
