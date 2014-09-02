//
//  SocialShare.m
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/5/19.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import "SocialShare.h"
#import <Social/Social.h>

@implementation SocialShare
{
    NSInteger newScore;
}

-(id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)showShareSheet:(ShareType)type viewController:(UIViewController *)viewcontroller
{
    if ([self checkInternetConnection]) {
        NSString *serviceType;
        switch (type) {
            case kShareTypeTwitter:
                serviceType = SLServiceTypeTwitter;
                break;
            case kShareTypeWeibo:
                serviceType = SLServiceTypeSinaWeibo;
                break;
            case kShareTypeFacebook:
                serviceType = SLServiceTypeFacebook;
                break;
            default:
                break;
        }
        
        //  Create an instance of the share Sheet , Service Type 有 Facebook/Twitter/微博 可以選
        SLComposeViewController *shareSheet = [SLComposeViewController composeViewControllerForServiceType: serviceType];
        
        shareSheet.completionHandler = ^(SLComposeViewControllerResult result) {
            switch(result) {
                    //  This means the user cancelled without sending the Tweet
                case SLComposeViewControllerResultCancelled:
                    break;
                    //  This means the user hit 'Send'
                case SLComposeViewControllerResultDone:
                    break;
            }
        };
        
        //  Set the initial body of the share sheet
        [shareSheet setInitialText:[NSString stringWithFormat:@"I have scored %ld points @ Bomb Block!",newScore]];
        
        //  Share Photo
        [shareSheet addImage:_screenshot];
        
        //  Presents the share Sheet to the user
        [viewcontroller presentViewController:shareSheet animated:NO completion:nil];
    }
}

- (void)setScore:(NSInteger)s
{
    newScore = s;
}

- (BOOL)checkInternetConnection
{
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        UIAlertView *noInternetAlert = [[UIAlertView alloc]initWithTitle: NSLocalizedString(@"No Internet Connection", nil)
                                                                 message:NSLocalizedString(@"Check your internet connection and try again",nil)
                                                                delegate:self cancelButtonTitle:NSLocalizedString(@"Close",nil)
                                                       otherButtonTitles:nil, nil];
        [noInternetAlert show];
        return NO;
    } else {
        return YES;
    }
}

@end
