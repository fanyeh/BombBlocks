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
        
        _assetImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self addSubview:_assetImageView];

    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code
        self.frame = CGRectMake(0, 0, 20, 20);
        _classicAssetLabel = [[UILabel alloc]initWithFrame:CGRectMake(4, 4, 12 ,12)];
        _classicAssetLabel.layer.masksToBounds = YES;
        [self addSubview:_classicAssetLabel];
        _gameAssetType = kAssetTypeEmpty;
        
        _assetImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [self addSubview:_assetImageView];
        
        _neighbors = [[NSMutableArray alloc]init];
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
    _assetImageView.image = nil;

    switch (type) {
        case kAssetTypeWall:
            self.backgroundColor = [UIColor blackColor];
//            _assetImageView.image = [UIImage imageNamed:@"wall.png"];
            self.assetName = @"Wall";
            break;
        case kAssetTypeMonster:
            self.backgroundColor = [UIColor redColor];
            self.assetName = @"Monster";
            break;
        case kAssetTypeSword:
//            self.backgroundColor = [UIColor colorWithRed:1.000 green:0.733 blue:0.125 alpha:1.000];
            _assetImageView.image = [UIImage imageNamed:@"sword.png"];

            self.assetName = @"Sword";
            break;
        case kAssetTypeShield:
//            self.backgroundColor = [UIColor colorWithRed:1.000 green:0.208 blue:0.545 alpha:1.000];
            _assetImageView.image = [UIImage imageNamed:@"shield.jpg"];

            self.assetName = @"Shield";
            break;
        case kAssetTypeMagic:
//            self.backgroundColor = [UIColor colorWithRed:0.235 green:0.729 blue:0.784 alpha:1.000];
            _assetImageView.image = [UIImage imageNamed:@"magic.png"];

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
        case kAssetTypePurple:
            _classicAssetLabel.backgroundColor = [UIColor colorWithRed:0.592 green:0.408 blue:0.820 alpha:1.000];
            _classicAssetLabel.layer.cornerRadius = _classicAssetLabel.frame.size.width/2;
            self.assetName = @"Purple";
            break;
        case kAssetTypeGoal:
            self.backgroundColor = [UIColor clearColor];
            _assetImageView.image = [UIImage imageNamed:@"teleport.jpg"];

            self.assetName = @"Goal";
            break;
        case kAssetTypeKey:
            self.backgroundColor = [UIColor clearColor];
            _assetImageView.image = [UIImage imageNamed:@"Key.png"];
            self.assetName = @"Key";
            break;
        case kAssetTypeMagicWall:
            self.backgroundColor = [UIColor brownColor];
            self.assetName = @"MagicWall";
            break;
        case kAssetTypeDoor:
            self.backgroundColor = [UIColor clearColor];
            _assetImageView.image = [UIImage imageNamed:@"door.png"];
            self.assetName = @"door";
            break;
    }
}

@end
