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
        
        _classicAssetLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, frame.size.width  , frame.size.height)];
        _classicAssetLabel.layer.masksToBounds = YES;
        [self addSubview:_classicAssetLabel];
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
        _classicAssetLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, self.frame.size.width/2  , self.frame.size.height/2)];
        _classicAssetLabel.layer.masksToBounds = YES;
        [self addSubview:_classicAssetLabel];
        _gameAssetType = kAssetTypeEmpty;
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
    _classicAssetLabel.layer.cornerRadius = 0;

    switch (type) {
        case kAssetTypeWall:
            self.backgroundColor = [UIColor colorWithRed:0.435 green:0.529 blue:0.529 alpha:1.000];
            self.assetName = @"Wall";
            break;
        case kAssetTypeMonster:
            self.backgroundColor = [UIColor redColor];
            self.assetName = @"Monster";
            break;
        case kAssetTypeSword:
            self.backgroundColor = [UIColor colorWithRed:1.000 green:0.733 blue:0.125 alpha:1.000];
            self.assetName = @"Sword";
            break;
        case kAssetTypeShield:
            self.backgroundColor = [UIColor colorWithRed:1.000 green:0.208 blue:0.545 alpha:1.000];
            self.assetName = @"Shield";
            break;
        case kAssetTypeMagic:
            self.backgroundColor = [UIColor colorWithRed:0.235 green:0.729 blue:0.784 alpha:1.000];
            self.assetName = @"Magic";
            break;
        case kAssetTypeEmpty:
            self.backgroundColor = [UIColor whiteColor];
            self.assetName = @"Empty";
            break;
        case kAssetTypeBlue:
            _classicAssetLabel.backgroundColor = [UIColor colorWithRed:0.235 green:0.729 blue:0.784 alpha:1.000];
            _classicAssetLabel.layer.cornerRadius = _classicAssetLabel.frame.size.width/2;

            self.assetName = @"Blue";
            break;
        case kAssetTypeRed:
            _classicAssetLabel.backgroundColor = [UIColor colorWithRed:1.000 green:0.208 blue:0.545 alpha:1.000];
            _classicAssetLabel.layer.cornerRadius = _classicAssetLabel.frame.size.width/2;

            self.assetName = @"Red";
            break;
        case kAssetTypeYellow:
            _classicAssetLabel.backgroundColor = [UIColor colorWithRed:1.000 green:0.733 blue:0.125 alpha:1.000];
            _classicAssetLabel.layer.cornerRadius = _classicAssetLabel.frame.size.width/2;
            self.assetName = @"Yellow";
            break;
        case kAssetTypeGoal:
            self.backgroundColor = [UIColor greenColor];
            self.assetName = @"Goal";
            break;
    }
    
}

@end
