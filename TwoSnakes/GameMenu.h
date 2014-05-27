//
//  GameMenu.h
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/5/21.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CircleLabel.h"
@interface GameMenu : UIView

@property (strong , nonatomic) CircleLabel *resumeLabel;
@property (strong , nonatomic) CircleLabel *retryLabel;
@property (strong , nonatomic) CircleLabel *homeLabel;
@property (strong , nonatomic) CircleLabel *levelLabel;

@end
