//
//  GamePad.h
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/5/19.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GameAsset;

@interface GamePad : UIView

//@property (strong,nonatomic) NSMutableArray *dotArray;
@property (strong,nonatomic) NSMutableArray *assetArray;

- (id)initGamePad;
- (id)initEmptyGamePad;
- (void)setupDotForGameStart:(CGRect)headFrame;
- (void)hideAllAssets;
- (void)changeAssetType:(GameAsset *)asset;
- (id)initGamePadWithAsset:(NSMutableArray *)gameAssets;
- (id)initGamePadWithAssetDict:(NSDictionary *)assets;
- (void)resetClassicGamePad;

@end
