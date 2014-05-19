//
//  SocialShare.h
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/5/19.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kShareTypeFacebook = 0,
    kShareTypeTwitter,
    kShareTypeWeibo
} ShareType;

@interface SocialShare : NSObject

- (void)showShareSheet:(ShareType)type viewController:(UIViewController *)viewcontroller;

@end
