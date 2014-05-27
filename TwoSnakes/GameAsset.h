//
//  GameAsset.h
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/5/22.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    kAssetTypeWall = 0,
    kAssetTypeMonster,
    kAssetTypeSword,
    kAssetTypeShield,
    kAssetTypeMagic,
    kAssetTypeEmpty,
    kAssetTypeYellow,
    kAssetTypeRed,
    kAssetTypeBlue,
    kAssetTypeGoal
} AssetType;

@interface GameAsset : UIView

@property (nonatomic) AssetType gameAssetType;
@property (strong,nonatomic) UILabel *classicAssetLabel;
@property (strong,nonatomic) NSString *assetName;
@property (strong,nonatomic) NSIndexPath *indexPath;

- (void)setPosition:(CGPoint)position;
- (void)setAssetType:(AssetType)type;


@end
