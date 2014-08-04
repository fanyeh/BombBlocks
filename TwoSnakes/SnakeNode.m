//
//  SnakeNode.m
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/7/17.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import "SnakeNode.h"

@implementation SnakeNode


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _nodeImageView = [[UIImageView alloc]initWithFrame:CGRectMake(8, 8, 24, 24)];
        [self addSubview:_nodeImageView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame gameAssetType:(AssetType)assetType imageFrame:(CGRect)imageFrame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _assetType = assetType;
        _nodeImageView = [[UIImageView alloc]initWithFrame:imageFrame];
        [self addSubview:_nodeImageView];

    }
    return self;
}

- (void)setNodeIndexRow:(int)row andCol:(int)col
{
    _nodePath.row = row;
    _nodePath.col = col;
}

-(int)nodeIndexRow
{
    return _nodePath.row;
}

-(int)nodeIndexCol
{
    return _nodePath.col;
}

@end
