//
//  ParticleView.h
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/6/23.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import "GameAsset.h"

typedef enum {
    kSoundTypeMoveSound = 0,
    kSoundTypeIntroMoveSound,
    kSoundTypeComboSound,
    kSoundTypeBreakSound,
    kSoundTypeButtonSound,
    kSoundTypeGameoverSound,
    kSoundTypeExplodeSound,
    kSoundTypeExplodeColorSound,
    kSoundTypeExplodeSquareSound,
    kSoundTypeGameSound,
    kSoundTypeScanSound,
    kSoundTypeTickSound,
    kSoundTypeSirenSound,
    kSoundTypeMenuBombDropSound,
    kSoundTypeRandomBombSound
} SoundType;

@interface ParticleView : SKScene

- (void)newExplosionWithPosX:(float)posX andPosY:(float)posY assetType:(AssetType)type;
//- (void)playMoveSound;
//- (void)introMoveSound;
//- (void)playComboSound;
//- (void)playButtonSound;
//- (void)playGameoverSound;
//- (void)explodeSound;
//- (void)explodeSquareSound;
//- (void)playBreakSound;
//- (void)explodeColorSound;
//- (void)playGameSound;
//- (void)scanSound;
//- (void)tickSound;
//- (void)sirenSound;
//- (void)menuBombDropSound;
//- (void)randomBombSound;

-(void)playSound:(SoundType)soundType;


@end
