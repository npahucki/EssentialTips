//
//  EssentialTipsAdView.h
//  EssentialTips
//
//  Created by Nathan  Pahucki on 7/9/14.
//  Copyright (c) 2015 InfantIQ. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, DataParentingAdViewSize) {
    DataParentingAdViewSizeSmall // 320x50
    // DataParentingAdViewSizeMedium // 213x320
};

@protocol DataParentingAdViewDelegate <NSObject>

@required
- (void)displayAdView;

- (void)hideAdView;

@optional
- (void)adClicked;

@end

@interface DataParentingAdView : UIView

@property DataParentingAdViewSize size;
@property(strong, nonatomic) id <DataParentingAdViewDelegate> delegate;
@property(weak, nonatomic) UIViewController *containingViewController;

@property(readonly) NSURL *currentAdLinkURL;
@property(readonly) NSURL *currentAdImageURL;
@property(readonly) NSInteger currentAdImageHeight;
@property(readonly) NSInteger currentAdImageWidth;

- (void)attemptAdLoad;


@end



