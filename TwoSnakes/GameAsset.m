//
//  GameAsset.m
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/5/22.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import "GameAsset.h"

@implementation GameAsset

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        _assetNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, frame.size.width  , frame.size.height)];
        _assetNameLabel.textColor = [UIColor whiteColor];
        _assetNameLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_assetNameLabel];
        _gameAssetType = kAssetTypeEmpty;

    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code
        self.frame = CGRectMake(0, 0, 20, 20);
        _assetNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width  , self.frame.size.height)];
        _assetNameLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_assetNameLabel];
        _gameAssetType = kAssetTypeEmpty;
        _assetNameLabel.textColor = [UIColor whiteColor];
        
    }
    return self;
}

- (void)setPosition:(CGPoint)position
{
    CGRect frame = self.frame;
    frame.origin = CGPointMake(position.x, position.y);
    self.frame = frame;
}

- (void)setAssetType:(AssetType)type;
{
    _gameAssetType = type;
    
    switch (type) {
        case kAssetTypeWall:
            self.backgroundColor = [UIColor blackColor];
            self.assetNameLabel.text = @"Wa";
            break;
        case kAssetTypeMonster:
            self.backgroundColor = [UIColor redColor];
            self.assetNameLabel.text = @"Mo";
            break;
        case kAssetTypeSword:
            self.backgroundColor = [UIColor colorWithRed:1.000 green:0.733 blue:0.125 alpha:1.000];
            self.assetNameLabel.text = @"Sw";
            break;
        case kAssetTypeShield:
            self.backgroundColor = [UIColor colorWithRed:1.000 green:0.208 blue:0.545 alpha:1.000];
            self.assetNameLabel.text = @"Sh";
            break;
        case kAssetTypeMagic:
            self.backgroundColor = [UIColor colorWithRed:0.235 green:0.729 blue:0.784 alpha:1.000];
            self.assetNameLabel.text = @"Ma";
            break;
        case kAssetTypeEmpty:
            self.backgroundColor = [UIColor whiteColor];
            self.assetNameLabel.text = @"Em";
            break;
    }
    
}

@end
