//
//  GamePad.m
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/5/19.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import "GamePad.h"
#import "GameAsset.h"

@implementation GamePad

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initGamePad
{
    CGRect frame = CGRectMake(0, 0, 315, 483);
    self = [self initWithFrame:frame];
    if (self) {
        // Initialization code
        [self createClassicGameAsset];
    }
    return self;
}

- (id)initEmptyGamePad
{
    CGRect frame = CGRectMake(2.5, 80, 315, 483);
    self = [self initWithFrame:frame];
    if (self) {
        // Initialization code
        [self createEmptyPad];        
    }
    return self;
}

- (id)initGamePadWithAsset:(NSMutableArray *)gameAssets
{
    CGRect frame = CGRectMake(2.5, 80, 315, 483);
    self = [self initWithFrame:frame];
    if (self) {
        // Initialization code
        _assetArray = gameAssets;
        [self createPadWithAssets];

    }
    return self;
}

- (void)createClassicGameAsset
{
    _assetArray = [[NSMutableArray alloc]init];
    CGFloat assetPosX;
    CGFloat assetPosY;
    
    for (int i = 0 ; i < 14; i ++ ) {
        for (int j = 0 ; j < 23 ; j++) {
            if (i%2==1 && j%2==1) {
                
                assetPosX = i * 21;
                assetPosY = j * 21;
                
                GameAsset *asset = [[GameAsset alloc]init];
                
                int randomAsset = arc4random()%3;
                
                switch (randomAsset) {
                    case 0:
                        [asset setAssetType:kAssetTypeMagic];
                        break;
                    case 1:
                        [asset setAssetType:kAssetTypeSword];
                        break;
                    case 2:
                        [asset setAssetType:kAssetTypeShield];
                        break;
                }
                
                [asset setPosition:CGPointMake(assetPosX, assetPosY)];
                [self addSubview:asset];
                [self sendSubviewToBack:asset];
                [_assetArray addObject:asset];
            }
        }
    }
}

- (void)createEmptyPad
{
    _assetArray = [[NSMutableArray alloc]init];
    CGFloat assetPosX;
    CGFloat assetPosY;
    
    for (int i = 0 ; i < 15; i ++ ) {
        for (int j = 0 ; j < 23 ; j++) {
            
            assetPosX = i * 21;
            assetPosY = j * 21;
        
            GameAsset *emptyAsset = [[GameAsset alloc]initWithFrame:CGRectMake(assetPosX, assetPosY, 20, 20)];
            emptyAsset.indexPath = [NSIndexPath indexPathForRow:i inSection:j];
            emptyAsset.layer.borderWidth = 1;
            [self addSubview:emptyAsset];
            [self sendSubviewToBack:emptyAsset];
            [_assetArray addObject:emptyAsset];
        }
    }
}

- (void)createPadWithAssets
{
    for (GameAsset *a in _assetArray) {
    
        GameAsset *newAsset = [[GameAsset alloc]init];
        [newAsset setAssetType:a.gameAssetType];
        CGFloat assetPosX = a.indexPath.row * 21;
        CGFloat assetPosY = a.indexPath.section * 21;
        
        [newAsset setPosition:CGPointMake(assetPosX, assetPosY)];
        
        newAsset.layer.borderWidth = 1;
        [self addSubview:newAsset];
        [self sendSubviewToBack:newAsset];
    }
}

- (void)changeAssetType:(GameAsset *)asset
{
    if ([_assetArray indexOfObject:asset]) {
        GameAsset *changeAsset = [_assetArray objectAtIndex:[_assetArray indexOfObject:asset]];
        CGPoint pos = changeAsset.frame.origin;
        
        int randomAsset = arc4random()%3;
        
        switch (randomAsset) {
            case 0:
                [changeAsset setAssetType:kAssetTypeMagic];
                break;
            case 1:
                [changeAsset setAssetType:kAssetTypeSword];
                break;
            case 2:
                [changeAsset setAssetType:kAssetTypeShield];
                break;
        }

        [changeAsset setPosition:pos];
    }
}


- (void)setupDotForGameStart:(CGRect)headFrame
{
//    self.alpha = 1;
//    for (SnakeDot *d in _dotArray) {
//        [d changeType];
//        d.alpha = 1;
//        if (CGRectIntersectsRect(d.frame, headFrame))
//            d.hidden = YES;
//    }
}

- (void)hideAllAssets
{
    for (GameAsset *v in _assetArray) {
        v.alpha = 0;
    }
}




@end
