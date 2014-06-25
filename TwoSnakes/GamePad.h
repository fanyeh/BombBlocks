//
//  GamePad.h
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/5/19.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Snake.h"
@class GameAsset;

@interface GamePad : UIView

@property (strong,nonatomic) NSMutableArray *assetArray;
@property (strong,nonatomic) UIView *skillView;
@property (strong,nonatomic) UIView *skillBackgroundView;

- (id)initGamePad;
- (void)setupDotForGameStart:(CGRect)headFrame;
- (void)hideAllAssets;
- (void)changeAssetType:(GameAsset *)asset;
- (void)resetClassicGamePad;
- (NSMutableArray *)searchPathPlayer:(CGRect)playerFrame enemy:(CGRect)enemyFrame moveDirection:(MoveDirection)moveDirection;
- (void)showSkillView;
- (void)hideSkillView;

@end
