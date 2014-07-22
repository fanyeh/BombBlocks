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
        self.frame = CGRectMake(0, 0,40,40);

        _gameAssetType = kAssetTypeEmpty;
        CGFloat imageViewSize = self.frame.size.width-16;
        CGFloat imageViewPos = (self.frame.size.width - imageViewSize)/2;
        _assetImageView = [[UIImageView alloc]initWithFrame:CGRectMake(imageViewPos, imageViewPos, imageViewSize, imageViewSize)];
        _assetImageView.layer.cornerRadius = (imageViewSize)/2;
        [self addSubview:_assetImageView];
        
        _neighbors = [[NSMutableArray alloc]init];
        
        //self.layer.cornerRadius = 10;
        
       // self.backgroundColor = [UIColor colorWithRed:0.248 green:0.323 blue:0.373 alpha:1.000];
        //self.layer.borderWidth = 2;
       // self.layer.borderColor = [UIColor colorWithRed:0.216 green:0.282 blue:0.322 alpha:1.000].CGColor;
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
    _assetImageView.image = nil;

    switch (type) {
            
        case kAssetTypeEmpty:
            break;
        case kAssetTypeBlue:
            _assetImageView.backgroundColor = BlueDotColor;
            //_assetImageView.image = [UIImage imageNamed:@"blue.png"];

            break;
        case kAssetTypeRed:
            _assetImageView.backgroundColor = RedDotColor;

            //_assetImageView.image = [UIImage imageNamed:@"red.png"];

            break;
        case kAssetTypeYellow:
            _assetImageView.backgroundColor = YellowDotColor;

            //_assetImageView.image = [UIImage imageNamed:@"yellow.png"];

            break;
        case kAssetTypeGreen:
            _assetImageView.backgroundColor = GreenDotColor;

            //_assetImageView.image = [UIImage imageNamed:@"green.png"];

            break;
           
    }
}

@end
