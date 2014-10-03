//
//  GameSettingViewController.h
//  Bomb Blocks
//
//  Created by Jack Yeh on 2014/9/12.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParticleView.h"

@protocol continueDelegate <NSObject>
@required

-(void)continueGameFromSetting;

@end

@interface GameSettingViewController : UIViewController
{
    __weak id<continueDelegate>_delegate;
}
@property (weak,nonatomic) id<continueDelegate>delegate;
@property (nonatomic,strong) UIImage *bgImage;
@property (nonatomic,strong) ParticleView *particleView;

@end
