//
//  GameAsset.h
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/5/22.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {

    kAssetTypeEmpty = 0,
    kAssetTypeYellow,
    kAssetTypeRed,
    kAssetTypeBlue,
    kAssetTypeGreen,
    kAssetTypePurple
    
} AssetType;

@interface GameAsset : UIView

@property (nonatomic) AssetType gameAssetType;
@property (strong,nonatomic) NSIndexPath *indexPath;
@property (strong,nonatomic) UIImageView *assetImageView;
@property (strong,nonatomic) NSMutableArray *neighbors;
@property (strong,nonatomic) GameAsset *pathParent;

- (void)setPosition:(CGPoint)position;
- (void)setAssetType:(AssetType)type;

@end
