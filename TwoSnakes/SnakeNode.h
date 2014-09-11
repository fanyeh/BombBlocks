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

typedef struct NodeIndex NodeIndex;

struct NodeIndex {
    NSInteger col;
    NSInteger row;
};

@interface SnakeNode : UIView

- (id)initWithFrame:(CGRect)frame gameAssetType:(AssetType)assetType;
- (id)initWithEmptyFrame:(CGRect)frame;
- (void)setBombWithReminder:(NSInteger)reminder complete:(void(^)(void))completBlock;
- (void)setNodeIndexRow:(NSInteger)row andCol:(NSInteger)col;
- (void)scoreLabelAnimation;
- (void)removeBomb;
- (void)hideScoreLabel;
- (void)addCountLabel;
- (void)reduceCount;
-(void)removeCountLabel;

@property (nonatomic,assign) AssetType assetType;
@property (nonatomic,assign) BombType bombType;
@property (nonatomic,assign) MoveDirection direction;
@property (nonatomic,strong) UIColor *nodeColor;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) UIImageView *nodeImageView;
@property (nonatomic,assign) NodeIndex nodePath;
@property (nonatomic,assign) NSInteger nodeColumn;
@property (nonatomic,assign) NSInteger nodeRow;
@property (nonatomic,assign) BOOL hasBomb;
@property (nonatomic,assign) BOOL hasCount;
@property (nonatomic,assign) NSInteger scoreAdder;
@property (nonatomic,assign) NSInteger level;
@property (nonatomic,assign) NSInteger count;

@end
