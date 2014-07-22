//
//  SnakeNode.m
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/7/17.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import "SnakeNode.h"

@implementation SnakeNode
{
    NodeIndex nodePath;

}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame gameAssetType:(AssetType)assetType
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _assetType = assetType;

    }
    return self;
}

- (void)setNodeIndexRow:(int)row andCol:(int)col
{
    nodePath.row = row;
    nodePath.col = col;
}

-(int)nodeIndexRow
{
    return nodePath.row;
}

-(int)nodeIndexCol
{
    return nodePath.col;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
