//
// Created by Nathan  Pahucki on 3/4/15.
///  Copyright (c) 2015 InfantIQ. All rights reserved.
//

#import "hipmob/HMService.h"
#import "hipmob/HMChatMessage.h"
#import <AudioToolbox/AudioToolbox.h>
#import "HipmobViewController.h"
#import "MainViewController.h"

@implementation HipmobViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.clipsToBounds = YES;

    self.titleLabel.font = [UIFont fontForAppWithType:Book andSize:18.0];
    self.titleLabel.textColor = [UIColor appTitleHeaderColor];
    self.titleLabel.text = @"Connecting To Support...";
    self.statusImageView.image = [UIImage animatedImageNamed:@"progress-" duration:1.0];

    NSString *hipMobAppId = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"DP.HipMobAppId"];
    ParentUser *user = [ParentUser currentUser];
    self.chatView = [[HMChatView alloc] initWithFrame:self.view.bounds andAppID:hipMobAppId andUser:user.objectId];
    if (user.hasEmail) [self.chatView updateEmail:user.email];
    if (user.fullName) [self.chatView updateName:user.fullName];

    self.chatView.sendMediaButtonSize = CGSizeZero;
    self.chatView.maxInputLines = 4;
    self.chatView.sentMessageFont = [UIFont fontForAppWithType:Medium andSize:16];
    self.chatView.sentTextColor = [UIColor whiteColor];
    self.chatView.receivedMessageFont = [UIFont fontForAppWithType:Bold andSize:18];
    self.chatView.receivedTextColor = [UIColor appNormalColor];
    self.chatView.receivedTextColor = [UIColor appNormalColor];
    self.chatView.delegate = self;
    self.chatView.table.backgroundColor = self.chatView.backgroundColor = [UIColor clearColor];
    [self.chatContainerView addSubview:self.chatView];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardWillShowNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    if ([self.chatView connect]) {
        self.titleLabel.text = @"Connecting To Support...";
        self.statusImageView.image = [UIImage animatedImageNamed:@"progress-" duration:1.0];
    }

    SlideOverViewController *slideOutController = (SlideOverViewController *) self.navigationController.parentViewController;
    MainViewController *mainViewController = (MainViewController *) slideOutController.mainViewController;
    UIViewController *currentVc = mainViewController.selectedViewController;
    if ([currentVc isKindOfClass:[UINavigationController class]]) {
        currentVc = ((UINavigationController *) currentVc).visibleViewController;
    }
    NSString *contextTitle = NSStringFromClass([currentVc class]);
    if (contextTitle) [self.chatView updateContext:contextTitle];
}

- (void)dealloc {
    [self.chatView disconnect];
}

- (void)keyboardWillBeHidden:(NSNotification *)aNotification {
    self.chatContainerBottomConstraint.constant = 0;
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWasShown:(NSNotification *)aNotification {
    NSDictionary *info = [aNotification userInfo];
    CGSize kbSize = [info[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    [UIView animateWithDuration:0.25 animations:^{
        self.chatContainerBottomConstraint.constant = kbSize.height;
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
    }];

    // Also need to scroll to bottom
    [self.chatView.table                                                            setContentOffset:CGPointMake(0,
            self.chatView.table.contentSize.height - self.chatView.table.frame.size.height) animated:YES];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.chatView.frame = self.chatContainerView.bounds;
    // Make the bottom of the Text field fade out
    CAGradientLayer *l = [CAGradientLayer layer];
    l.frame = self.chatContainerView.bounds;
    l.colors = @[(id) [UIColor clearColor].CGColor, (id) [UIColor whiteColor].CGColor];
    l.locations = @[@0.0F, @0.02F,];
    self.chatContainerView.layer.mask = l;

}


- (void)viewDidConnect:(id)chatView {
    self.titleLabel.text = @"How can we help?";
    self.statusImageView.image = [UIImage imageNamed:@"success-8"];
}

- (void)chatView:(id)chatView didSendMessage:(HMChatMessage *)message {
    AudioServicesPlaySystemSound(1004);

}

- (void)chatView:(id)chatView didReceiveMessage:(HMChatMessage *)message {
    AudioServicesPlaySystemSound(1003);
    self.titleLabel.text = [NSString stringWithFormat:@"Chatting with %@", message.from];
    self.statusImageView.image = [UIImage imageNamed:@"success-8"];
}

- (void)viewDidDisconnect:(id)chatView {
    self.titleLabel.text = @"Not Connected";
    self.statusImageView.image = [UIImage imageNamed:@"progress-0"];
}

- (void)chatView:(id)chatView didErrorOccur:(NSString *)error {
    self.titleLabel.text = @"Could not Connect";
    self.statusImageView.image = [UIImage imageNamed:@"error-9"];
    if (self.chatView.isConnected) [self.chatView disconnect];
    //[UsageAnalytics trackError:error forOperationNamed:@"contactSupport"];
    NSLog(@"Chat Error %@", error);
}

- (void)chatView:(id)chatView isReady:(NSDictionary *)connectionDefaults {
    self.titleLabel.text = @"Connected to Support";
    self.statusImageView.image = [UIImage imageNamed:@"success-8"];
}

- (void)chatView:(id)chatView didOperatorAccept:(NSString *)operatorId {
    self.titleLabel.text = [NSString stringWithFormat:@"Chatting with %@", operatorId];
    self.statusImageView.image = [UIImage imageNamed:@"success-8"];
}

- (void)viewDidOperatorComeOnline:(id)chatView {
}

- (void)viewDidOperatorGoOffline:(id)chatView {
}


@end