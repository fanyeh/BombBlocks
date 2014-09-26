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
        
        NSNumberFormatter *numFormatter = [[NSNumberFormatter alloc] init];
        [numFormatter setGroupingSeparator:@","];
        [numFormatter setGroupingSize:3];
        [numFormatter setUsesGroupingSeparator:YES];
        
        //  Set the initial body of the share sheet
        NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
        if ([language isEqualToString:@"zh-Hans"]) {

            [shareSheet setInitialText:[NSString stringWithFormat:@"我从块爆了得到 %@ 分!",[numFormatter stringFromNumber:[NSNumber numberWithInteger:newScore]]]];
            
        } else if ([language isEqualToString:@"zh-Hant"]) {

            [shareSheet setInitialText:[NSString stringWithFormat:@"我從塊爆了得到 %@ 分!",[numFormatter stringFromNumber:[NSNumber numberWithInteger:newScore]]]];
            
        } else if ([language isEqualToString:@"ja"]) {
            
            [shareSheet setInitialText:[NSString stringWithFormat:@"ブロック爆発で %@ ポイントを獲得してきた!",[numFormatter stringFromNumber:[NSNumber numberWithInteger:newScore]]]];
            
        }else {
            [shareSheet setInitialText:[NSString stringWithFormat:@"I have scored %@ points @ Bomb Blocks!",[numFormatter stringFromNumber:[NSNumber numberWithInteger:newScore]]]];
        }

        //  Share Photo
        [shareSheet addImage:_screenshot];
        
        NSURL *appURL = [NSURL URLWithString:@"https://itunes.apple.com/app/bomb-boom-blocks/id916465725?l=zh&ls=1&mt=8"];
        [shareSheet addURL:appURL];
        
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
