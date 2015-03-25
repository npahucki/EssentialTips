//
//  WebViewerViewController.h
//  Milestones
//
//  Created by Nathan  Pahucki on 5/28/14.
//  Copyright (c) 2015 InfantIQ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewerViewController : UIViewController <UIWebViewDelegate>
@property(weak, nonatomic) IBOutlet UIWebView *webView;
@property NSURL *url;

@property(weak, nonatomic) IBOutlet UIImageView *loadingImage;

@property(weak, nonatomic) IBOutlet UIButton *closeButton;

+ (WebViewerViewController *)webViewForUrlString:(NSString *)url;

+ (WebViewerViewController *)webViewForUrl:(NSURL *)url;


@end
