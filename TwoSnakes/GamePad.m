//
//  GamePad.m
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/5/19.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import "GamePad.h"
#import "GameAsset.h"
#import "SnakeNode.h"

@implementation GamePad

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark - Classic Game

- (id)initGamePad
{
    CGFloat nodeHeight = 62;//85;
    CGFloat nodeWidth = 62;//65;
    int column = 5;
    int row = 5;
    CGFloat gapBetweenCard = 2;
    CGFloat gapFromBoundary = 3;
    CGRect frame = CGRectMake(0, 0, nodeWidth*column+gapFromBoundary*2-gapBetweenCard, nodeHeight*row+gapFromBoundary*2-gapBetweenCard);

    self = [self initWithFrame:frame];
    if (self) {
        // Initialization code
        _emptyNodeArray = [[NSMutableArray alloc]init];
        int randomX = arc4random() % column;
        int randomY = arc4random() % row;
        int tag = 0;
        for (int i = 0 ; i < column; i ++ ) {
            
            for (int j = 0 ; j < row ; j++) {
                
                CGFloat assetPosX = gapFromBoundary+nodeWidth*i;
                CGFloat assetPosY = gapFromBoundary+nodeHeight*j;
                SnakeNode *emptyNode = [[SnakeNode alloc]initWithEmptyFrame:CGRectMake(assetPosX, assetPosY, nodeWidth - gapBetweenCard, nodeHeight - gapBetweenCard)];
                [emptyNode setNodeIndexRow:j andCol:i];
                emptyNode.tag = tag;

                [self addSubview:emptyNode];
                [_emptyNodeArray addObject:emptyNode];
                
                if (i == randomX && j == randomY) {
                    _initialNode = emptyNode;
                }
                
                tag++;
            }
        }
    }
    return self;
}

-(void)showEmptyNodeBorder:(SnakeNode *)node
{
    UIColor *color;
    
    switch (node.assetType) {
        case kAssetTypeGreen:
            color = GreenDotColor;
            break;
        case kAssetTypeBlue:
            color = BlueDotColor;
            break;
        case kAssetTypeRed:
            color = RedDotColor;
            break;
        case kAssetTypeYellow:
            color = YellowDotColor;
            break;
        case kAssetTypeGrey:
            color = GreyDotColor;
            break;
        case kAssetTypeOrange:
            color = OrangeDotColor;
            break;
    }
    
    for (SnakeNode *emptyNode in _emptyNodeArray) {

        if (emptyNode.nodeRow == node.nodeRow && emptyNode.nodeColumn == node.nodeColumn) {

            emptyNode.layer.borderColor = color.CGColor;
        }
    }
}

-(void)resetEmptyNodeBorder
{
    for (SnakeNode *emptyNode in _emptyNodeArray) {
        
        emptyNode.layer.borderColor = FontColor.CGColor;
    }
}

-(void)createBombWithReminder:(NSInteger)reminder body:(NSMutableArray *)snakeBody complete:(void(^)(void))completBlock

{
    NSMutableArray *vacantNode = [[NSMutableArray alloc]init];
    for (SnakeNode *emptyNode in _emptyNodeArray) {
        
        if (!emptyNode.hasBomb) {
            BOOL hasNode = NO;
            for (SnakeNode *bodyNode in snakeBody) {
                if (emptyNode.nodeRow == bodyNode.nodeRow && emptyNode.nodeColumn == bodyNode.nodeColumn) {
                    hasNode = YES;
                    break;
                }
            }
            if (!hasNode)
                [vacantNode addObject:emptyNode];
        }
    }
    
    int rand = arc4random() % [vacantNode count];
    
    SnakeNode *bombNode = [vacantNode objectAtIndex:rand];
    [bombNode setBombWithReminder:reminder complete:completBlock];
}

-(void)reset
{
    for (SnakeNode *emptyNode in _emptyNodeArray) {
        
        [emptyNode removeBomb];
    }
}

- (void)bombExplosionWithPosX:(float)posX andPosY:(float)posY bomb:(SnakeNode *)bomb
{
    UIView *beamView1;
    UIView *beamView2;
    CGFloat beamSize = 10;
    
    if (bomb.bombType == kBombTypeExplodeVertical) {

        beamView1 = [[UIView alloc]initWithFrame:CGRectMake(posX-beamSize/2,posY-beamSize/2,beamSize,0)];
        beamView2 = [[UIView alloc]initWithFrame:CGRectMake(posX-beamSize/2,posY-beamSize/2,beamSize,0)];

        
    } else if (bomb.bombType == kBombTypeExplodeHorizontal) {
        
        beamView1 = [[UIView alloc]initWithFrame:CGRectMake(posX-beamSize/2,posY-beamSize/2,0,beamSize)];
        beamView2 = [[UIView alloc]initWithFrame:CGRectMake(posX-beamSize/2,posY-beamSize/2,0,beamSize)];
    }
    
    [self addSubview:beamView1];
    [self addSubview:beamView2];

    beamView1.backgroundColor = bomb.nodeColor;
    beamView2.backgroundColor = bomb.nodeColor;

    beamView1.alpha = 0.8;
    beamView2.alpha = 0.8;
    
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        if (bomb.bombType == kBombTypeExplodeVertical) {

            beamView1.frame = CGRectMake(posX-1/2,posY-1/2,1,-350);
            beamView2.frame = CGRectMake(posX-1/2,posY-1/2,1,350);
            
        } else if (bomb.bombType == kBombTypeExplodeHorizontal) {

            beamView1.frame = CGRectMake(posX-1/2,posY-1/2,-350,1);
            beamView2.frame = CGRectMake(posX-1/2,posY-1/2,350,1);
        }
        
        beamView1.alpha = 0.3;
        beamView2.alpha = 0.3;

    } completion:^(BOOL finished) {
        
        [beamView1 removeFromSuperview];
        [beamView2 removeFromSuperview];

    }];
}

- (void)bombExplosionSquare:(float)posX andPosY:(float)posY bomb:(SnakeNode *)bomb
{
    CGFloat beamSize1 = 67*2+31;
    UIView *beamView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, beamSize1, beamSize1)];
    beamView.center = CGPointMake(posX, posY);
    //beamView.backgroundColor = bomb.nodeColor;
    beamView.layer.borderWidth = 5;
    beamView.layer.borderColor = bomb.nodeColor.CGColor;
    beamView.layer.cornerRadius = beamSize1/2;
    beamView.alpha = 1;

    [self addSubview:beamView];

    CGAffineTransform t = beamView.transform;

    beamView.transform = CGAffineTransformScale(t, 0.3, 0.3);

    [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        beamView.alpha = 0.6;

        beamView.transform = t;

    } completion:^(BOOL finished) {
        
        [beamView removeFromSuperview];

    }];
}

@end
