//
//  PFFacebookUtils+PFFacebookUtils_Extras.m
//  Milestones
//
//  Created by Nathan  Pahucki on 6/5/14.
//  Copyright (c) 2015 InfantIQ. All rights reserved.
//

#import "NSDate+Utils.h"


@implementation PFFacebookUtils (PFFacebookUtils_Extras)


+ (BOOL)userHasAuthorizedPublishPermissions:(PFUser *)user {
    return [PFFacebookUtils isLinkedWithUser:user] && [[[PFFacebookUtils session] permissions] containsObject:@"publish_actions"];
}

+ (void)ensureHasPublishPermissions:(PFUser *)user block:(PFBooleanResultBlock)block {
    if ([PFFacebookUtils isLinkedWithUser:user]) {
        if ([[[PFFacebookUtils session] permissions] containsObject:@"publish_actions"]) {
            block(YES, nil);
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Proceed?" message:@"You have to give us permission to publish on Facebook to share your milestones." delegate:nil cancelButtonTitle:@"Not Now" otherButtonTitles:@"Let's Do It", nil];
            [alert showWithButtonBlock:^(NSInteger buttonIndex) {
                if (buttonIndex == 0) {
                    // cancel
                    [UsageAnalytics trackUserLinkedWithFacebook:(ParentUser *) user forPublish:YES withError:[NSError errorWithDomain:@"DataParenting" code:kDDErrorUserRefusedFacebookPermissions userInfo:nil]];
                    block(NO, nil);
                } else {
                    [PFFacebookUtils reauthorizeUser:user withPublishPermissions:FB_PUBLISH_PERMISSION_ARRAY audience:FBSessionDefaultAudienceFriends block:^(BOOL succeeded, NSError *error) {
                        [UsageAnalytics trackUserLinkedWithFacebook:(ParentUser *) user forPublish:YES withError:error];
                        // If the user denies Auth, the success flag is incorrectly set to true...
                        // so we need to check the permissions to determine if it succeeded
                        succeeded = succeeded && [[[PFFacebookUtils session] permissions] containsObject:@"publish_actions"];
                        block(succeeded, error);
                    }];
                }
            }];
        }
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Proceed?" message:@"You have to sign into Facebook to share." delegate:nil cancelButtonTitle:@"Not Now" otherButtonTitles:@"Let's Do It", nil];
        [alert showWithButtonBlock:^(NSInteger buttonIndex) {
            if (buttonIndex == 0) {
                // cancel
                block(NO, nil);
            } else {
                NSAssert(user != nil, @"Did not expect a anonymous user here!");
                [PFFacebookUtils linkUser:user permissions:FB_PUBLISH_PERMISSION_ARRAY block:^(BOOL succeeded, NSError *error) {
                    [UsageAnalytics trackUserLinkedWithFacebook:(ParentUser *) user forPublish:YES withError:error];
                    if (succeeded) {
                        // this will be done in the background
                        [PFFacebookUtils populateCurrentUserDetailsFromFacebook:(ParentUser *) user block:nil];
                    }
                    block(succeeded, error);
                }];
            }
        }];
    }
}

+ (void)populateCurrentUserDetailsFromFacebook:(ParentUser *)user block:(PFBooleanResultBlock)block {
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (result) {
            NSString *facebookEMail = result[@"email"];
            NSString *usersName = result[@"name"];
            NSString *gender = result[@"gender"];

            if (facebookEMail.length) {
                user.email = user.username = facebookEMail;
            } else {
                // This is a hack since we can't detect a facebook login in Cloud Code
                // and the user may either deny us his email or simply may not have one.
                // We set this flag here to work around that.
                [user setObject:@(YES) forKey:@"needsTipAssignmentNow"];
            }

            if ([@"male" isEqualToString:gender]) {
                user.isMale = YES;
            } else if ([@"female" isEqualToString:gender]) {
                user.isMale = NO;
            } // else don't set it

            if (usersName.length) {
                user.fullName = usersName;
            }


            [user saveEventually:^(BOOL succeeded, NSError *saveError) {
                if (saveError) [UsageAnalytics trackError:saveError forOperationNamed:@"saveUserFacebookInformation"];
                if (block) block(succeeded, saveError);
            }];
        } else {
            if (error) [UsageAnalytics trackError:error forOperationNamed:@"facebookAboutMeRequest"];
            if (block) block(NO, error);
        }
    }];
}


+ (void)showFacebookErrorAlert:(NSError *)error {
    [UsageAnalytics trackError:error forOperationNamed:@"FacebookOperation"];
    if ([error.domain isEqualToString:@"Parse"] && error.code == 208) {
        NSString *msg = @"There is another DataParenting account aready linked to that Facebook account. Please either use that DataParenting account, another Facebook account, or contact support.";
        [[[UIAlertView alloc] initWithTitle:@"Duplicate Facebook Account"
                                    message:msg
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    } else if ([error.domain isEqualToString:@"com.facebook.sdk"] && [error.userInfo[@"com.facebook.sdk:ErrorLoginFailedReason"] isEqualToString:@"com.facebook.sdk:SystemLoginDisallowedWithoutError"]) {
        NSString *msg = @"Please go to Settings->Facebook and enable acceess for 'DataParenting', then try to log in again.";
        [[[UIAlertView alloc] initWithTitle:@"Facebook Login Is Disabled"
                                    message:msg
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    } else if ([error.domain isEqualToString:@"com.facebook.sdk"] && [error.userInfo[@"com.facebook.sdk:ErrorLoginFailedReason"] isEqualToString:@"com.facebook.sdk:SystemLoginCancelled"]) {
        NSString *msg = @"Please go to Settings->Facebook and update your login information";
        [[[UIAlertView alloc] initWithTitle:@"Facebook Token Invalid"
                                    message:msg
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    } else if ([error.domain isEqualToString:@"com.facebook.sdk"] && [error.userInfo[@"com.facebook.sdk:ErrorLoginFailedReason"] isEqualToString:@"com.facebook.sdk:UserLoginCancelled"]) {
        NSString *msg = @"Facebook related features will not be available until you login sucessfully";
        [[[UIAlertView alloc] initWithTitle:@"You Canceled Facebook Login"
                                    message:msg
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    } else if ([error fberrorUserMessage]) {
        [[[UIAlertView alloc] initWithTitle:[error fberrorUserTitle] ?: @"Facebook Login Failed"
                                    message:[error fberrorUserMessage]
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Could Link With Facebook" message:[@"Something went wrong while signing"
                        " into Facebook, trying again now or later may fix the problem" stringByAppendingString:error.localizedDescription]
                                   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];

    }
}


@end
