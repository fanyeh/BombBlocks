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
@property (strong,nonatomic) NSMutableArray *indexpathArray;


- (id)initGamePad;
- (void)hideAllAssets;
- (void)changeAssetType:(GameAsset *)asset;
- (void)resetClassicGamePad;

@end
