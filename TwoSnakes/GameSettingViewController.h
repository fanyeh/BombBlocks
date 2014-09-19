//
//  GameSettingViewController.h
//  Bomb Blocks
//
//  Created by Jack Yeh on 2014/9/12.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol continueDelegate <NSObject>
@required

-(void)continueGame;

@end

@interface GameSettingViewController : UIViewController
{
    __weak id<continueDelegate>_delegate;
}
@property (weak,nonatomic) id<continueDelegate>delegate;

@end
