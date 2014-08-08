//
//  SnakeNode.h
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/7/17.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameAsset.h"

typedef enum {
    kMoveDirectionUp = 0,
    kMoveDirectionDown,
    kMoveDirectionLeft,
    kMoveDirectionRight
} MoveDirection;

struct NodeIndex {
    int row;
    int col;
};

typedef struct NodeIndex NodeIndex;

@interface SnakeNode : UIView

- (id)initWithFrame:(CGRect)frame gameAssetType:(AssetType)assetType imageFrame:(CGRect)imageFrame;
- (void)setNodeIndexRow:(int)row andCol:(int)col;
-(int)nodeIndexRow;
-(int)nodeIndexCol;

@property (nonatomic,assign) AssetType assetType;
@property (nonatomic,assign) MoveDirection direction;
@property (nonatomic,assign) NodeIndex nodePath;
@property (nonatomic,strong) UIColor *nodeColor;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) UIImageView *nodeImageView;

@end
