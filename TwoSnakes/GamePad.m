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
{
    NSMutableArray *gameAssets;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark - Classic Game

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
                        [asset setAssetType:kAssetTypeBlue];
                        break;
                    case 1:
                        [asset setAssetType:kAssetTypeRed];
                        break;
                    case 2:
                        [asset setAssetType:kAssetTypeYellow];
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

- (void)changeAssetType:(GameAsset *)asset
{
    if ([_assetArray indexOfObject:asset]) {
        GameAsset *changeAsset = [_assetArray objectAtIndex:[_assetArray indexOfObject:asset]];
        CGPoint pos = changeAsset.frame.origin;
        
        int randomAsset = arc4random()%3;
        
        switch (randomAsset) {
            case 0:
                [changeAsset setAssetType:kAssetTypeBlue];
                break;
            case 1:
                [changeAsset setAssetType:kAssetTypeRed];
                break;
            case 2:
                [changeAsset setAssetType:kAssetTypeYellow];
                break;
        }
        
        [changeAsset setPosition:pos];
    }
}

- (void)resetClassicGamePad
{
    for (GameAsset *a in _assetArray) {
        
        int randomAsset = arc4random()%3;
        
        switch (randomAsset) {
            case 0:
                [a setAssetType:kAssetTypeBlue];
                break;
            case 1:
                [a setAssetType:kAssetTypeRed];
                break;
            case 2:
                [a setAssetType:kAssetTypeYellow];
                break;
        }
    }
}

#pragma mark - Puzzle Maker

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

#pragma mark - Puzzle Trial

- (id)initGamePadWithAsset:(NSMutableArray *)assets
{
    CGRect frame = CGRectMake(2.5, 80, 315, 483);
    self = [self initWithFrame:frame];
    if (self) {
        // Initialization code
        gameAssets = assets;
        _assetArray = [[NSMutableArray alloc]init];

        [self createPadWithAssets];

    }
    return self;
}

- (void)createPadWithAssets
{
    for (GameAsset *a in gameAssets) {
        
        GameAsset *newAsset = [[GameAsset alloc]init];
        [newAsset setAssetType:a.gameAssetType];
        CGFloat assetPosX = a.indexPath.row * 21;
        CGFloat assetPosY = a.indexPath.section * 21;
        
        [newAsset setPosition:CGPointMake(assetPosX, assetPosY)];
        
        //        newAsset.layer.borderWidth = 1;
        [self addSubview:newAsset];
        [self sendSubviewToBack:newAsset];
        
        [_assetArray addObject:newAsset];
    }
}

#pragma mark - Puzzle Play

- (id)initGamePadWithAssetDict:(NSDictionary *)assets
{
    CGRect frame = CGRectMake(2.5, 80, 315, 483);
    self = [self initWithFrame:frame];
    if (self) {
        // Initialization code
        _assetArray = [[NSMutableArray alloc]init];
        
        [self createPadWithAssetsDict:assets];
        
    }
    return self;
}

- (void)createPadWithAssetsDict:(NSDictionary *)assetsDict
{
    NSArray *assets = [assetsDict allValues];
    for (NSDictionary *a in assets) {
        
        GameAsset *newAsset = [[GameAsset alloc]init];
        NSNumber *assetType = [a objectForKey:@"AssetType"];
        NSNumber *row = [a objectForKey:@"Row"];
        NSNumber *column = [a objectForKey:@"Column"];
        
        NSInteger assetPosX = [row integerValue] * 21;
        NSInteger assetPosY = [column integerValue] * 21;
        
        [newAsset setAssetType:[assetType intValue]];
        [newAsset setPosition:CGPointMake(assetPosX, assetPosY)];
        
        [self addSubview:newAsset];
        [self sendSubviewToBack:newAsset];
        
        [_assetArray addObject:newAsset];
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
