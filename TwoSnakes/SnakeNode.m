//
//  SnakeNode.m
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/7/17.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import "SnakeNode.h"
#import "CustomLabel.h"

@implementation SnakeNode
{
    CustomLabel *scoreLabel;
    CustomLabel *countLabel;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        CGFloat nextNodeSize = frame.size.width*0.6;
        CGFloat position = (frame.size.width - nextNodeSize) / 2;
        _nodeImageView = [[UIImageView alloc]initWithFrame:CGRectMake(position, position, nextNodeSize, nextNodeSize)];
        [self addSubview:_nodeImageView];
        self.layer.cornerRadius = 2;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame gameAssetType:(AssetType)assetType
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        CGFloat gapFromBound = 18;
        CGFloat scoreFontSize = 18;
        CGFloat scorePosY = 10;
        
        if (IS_IPad) {
            gapFromBound = gapFromBound/IPadMiniRatio;
            scoreFontSize = scoreFontSize/IPadMiniRatio;
            scorePosY= scorePosY/IPadMiniRatio;
        } else if (screenHeight > 568) {
            gapFromBound = gapFromBound * frame.size.width/60;
            scoreFontSize = scoreFontSize * frame.size.width/60;
            scorePosY= scorePosY * frame.size.width/60;
        }
        
        CGFloat imageSize = frame.size.width - gapFromBound;
        CGRect imageViewRect = CGRectMake((frame.size.width-imageSize)/2,(frame.size.height-imageSize)/2,imageSize,imageSize);
        _assetType = assetType;
        _nodeImageView = [[UIImageView alloc]initWithFrame:imageViewRect];
        [self addSubview:_nodeImageView];
        
        // Block score Label
        scoreLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(0,scorePosY,self.frame.size.width,scoreFontSize) fontSize:scoreFontSize];
        [self addSubview:scoreLabel];
        scoreLabel.alpha = 0;

        _hasCount = NO;
    }
    return self;
}

- (id)initWithEmptyFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.layer.cornerRadius = 3;
        self.layer.masksToBounds = YES;
        self.layer.borderWidth = 2.5;
        if (IS_IPad)
            self.layer.borderWidth = 2.5/IPadMiniRatio;
        self.layer.borderColor = FontColor.CGColor;
        _hasBomb = NO;
    }
    return self;
}

- (void)setBombWithReminder:(NSInteger)reminder complete:(void(^)(void))completBlock
{
    // Initialization code
    CGFloat gapFromBound = 10;
    CGFloat scoreFontSize = 18;
    CGFloat scorePosY = 10;

    if (IS_IPad) {
        scoreFontSize = scoreFontSize/IPadMiniRatio;
        gapFromBound = gapFromBound/IPadMiniRatio;
        scorePosY= scorePosY/IPadMiniRatio;
    } else if (screenHeight > 568) {
        gapFromBound = gapFromBound * self.frame.size.width/60;
        scoreFontSize = scoreFontSize * self.frame.size.width/60;
        scorePosY= scorePosY * self.frame.size.width/60;
    }

    // Set up node image
    CGFloat imageSize = self.frame.size.width - gapFromBound;
    CGRect imageViewRect = CGRectMake(gapFromBound/2,gapFromBound/2,imageSize,imageSize);
    _nodeImageView = [[UIImageView alloc]initWithFrame:imageViewRect];
    [self addSubview:_nodeImageView];
    
    // Block score Label
    scoreLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(0,scorePosY,self.frame.size.width,scoreFontSize )fontSize:scoreFontSize];
    [self addSubview:scoreLabel];
    scoreLabel.alpha = 0;
    
    // Determin bomb color
    
    int randAsset;
    if (reminder > 3)
        randAsset = arc4random()%4;
    else
        randAsset = arc4random()%3;
    
//    int randAsset = arc4random()%4; // Non level test

    // Set bomb color image
    switch (randAsset) {
        case 0:
            _nodeImageView.image = [UIImage imageNamed:@"bomb_blue.png"];
            _assetType = kAssetTypeBlue;
            _nodeColor = BlueDotColor;
            break;
        case 1:
            _nodeImageView.image = [UIImage imageNamed:@"bomb_red.png"];
            _assetType = kAssetTypeRed;
            _nodeColor = RedDotColor;
            break;
        case 2:
            _nodeImageView.image = [UIImage imageNamed:@"bomb_green.png"];
            _assetType = kAssetTypeGreen;
            _nodeColor = GreenDotColor;
            break;
        case 3:
            _nodeImageView.image = [UIImage imageNamed:@"bomb_yellow.png"];
            _assetType = kAssetTypeYellow;
            _nodeColor = YellowDotColor;
            break;
    }
    
    // Determine bomb type
    
    int randBomb;
    if (reminder < 5)
        randBomb = arc4random()%2;
    else if (reminder == 5)
        randBomb = arc4random()%3;
    else if (reminder == 6)
        randBomb = arc4random()%4;
    else if (reminder > 6)
        randBomb = arc4random()%5;
    
//    int randBomb = arc4random()%5; // Non level test

    // Bomb Type Image
    CGFloat bombSize = imageSize/2;
    UIImageView *bombImageView = [[UIImageView alloc]initWithFrame:CGRectMake((imageSize-bombSize)/2,(imageSize-bombSize)/2,bombSize,bombSize)];
    
    // Set bomb type
    switch (randBomb) {
        case 0:
            _bombType = kBombTypeExplodeHorizontal;
            bombImageView.image = [UIImage imageNamed:@"explodeHorizontal.png"];
            break;
        case 1:
            _bombType = kBombTypeExplodeVertical;
            bombImageView.image = [UIImage imageNamed:@"explodeVertical.png"];
            break;
        case 2:
            _bombType = kBombTypeRandom;
            bombImageView.image = [UIImage imageNamed:@"randomBomb.png"];
            break;
        case 3:
            _bombType = kBombTypeSquareExplode;
            bombImageView.image = [UIImage imageNamed:@"squareExplode.png"];
            break;
        case 4:
            _bombType = kBombTypeExplodeBlock;
            bombImageView.image = [UIImage imageNamed:@"explode.png"];
            break;
    }
    [_nodeImageView addSubview:bombImageView];

    // Node is a bomb
    self.hasBomb = YES;
    
    // Animation to populate new body
    CGAffineTransform t = _nodeImageView.transform;
    _nodeImageView.transform = CGAffineTransformScale(t, 0.5, 0.5);
    [UIView animateWithDuration:0.3 animations:^{
        
        _nodeImageView.transform = t;
        
    } completion:^(BOOL finished) {
        completBlock();
    }];
}

-(void)removeBomb
{
    _hasBomb = NO;
    [_nodeImageView removeFromSuperview];
    [scoreLabel removeFromSuperview];
}

- (void)setNodeIndexRow:(NSInteger)row andCol:(NSInteger)col
{
    _nodeRow = row;
    _nodeColumn = col;
    _nodePath.row = row;
    _nodePath.col = col;
}

-(void)scoreLabelAnimation
{
    [self bringSubviewToFront:scoreLabel];
    scoreLabel.text = [NSString stringWithFormat:@"+%ld",self.scoreAdder];
    scoreLabel.alpha = 1;
    if (IS_IPad)
        scoreLabel.frame = CGRectOffset(scoreLabel.frame, 0, -10/IPadMiniRatio);
    else
        scoreLabel.frame = CGRectOffset(scoreLabel.frame, 0, -10);
}

-(void)hideScoreLabel
{
    scoreLabel.alpha = 0;
    if (IS_IPad)
        scoreLabel.frame = CGRectOffset(scoreLabel.frame, 0, 10/IPadMiniRatio);
    else
        scoreLabel.frame = CGRectOffset(scoreLabel.frame, 0, 10);
}

-(void)addCountLabel
{
    _hasCount = YES;
    _count = 9;
    CGFloat size = 15;
    CGFloat yOffset = 3;
    
    if (IS_IPad) {
        size = size/IPadMiniRatio;
        yOffset = yOffset/IPadMiniRatio;
    } else if (screenHeight > 568 && IS_IPhone) {
        
        size = size * screenWidth/320;
        yOffset = yOffset * screenWidth/320;
    }
    
    CGFloat pos = (self.frame.size.width-size-1);
    countLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(pos,yOffset,size,size) fontSize:size];
    countLabel.text = [NSString stringWithFormat:@"%ld",_count];
    [self addSubview:countLabel];
}

-(void)hideCountLabel
{
    countLabel.hidden = YES;
}

-(void)removeCountLabel
{
    _hasCount = NO;
    [countLabel removeFromSuperview];
}

-(void)reduceCount
{
    _count --;
    if (_count > 0)
        countLabel.text = [NSString stringWithFormat:@"%ld",_count];
    else {
        _level = 3;
        _hasCount = NO;

        
        [UIView animateWithDuration:0.2 animations:^{
            
            _nodeImageView.alpha = 0;
            countLabel.alpha = 0;
            
        } completion:^(BOOL finished) {
            
            [countLabel removeFromSuperview];
            switch (_assetType) {
                case kAssetTypeBlue:
                    _nodeImageView.image = [UIImage imageNamed:@"blue_3.png"];
                    break;
                case kAssetTypeRed:
                    _nodeImageView.image = [UIImage imageNamed:@"red_3.png"];
                    break;
                case kAssetTypeGreen:
                    _nodeImageView.image = [UIImage imageNamed:@"green_3.png"];
                    break;
                case kAssetTypeYellow:
                    _nodeImageView.image = [UIImage imageNamed:@"yellow_3.png"];
                    break;
            }
            _nodeImageView.alpha = 1;

            CGAffineTransform t = _nodeImageView.transform;
            CGAffineTransform t2 = CGAffineTransformScale(t, 1.2, 1.2);
            _nodeImageView.transform = CGAffineTransformScale(t, 0.3, 0.3);
            
            [UIView animateWithDuration:0.15 animations:^{
                
                _nodeImageView.transform = t2;
                
            } completion:^(BOOL finished) {
                
                [UIView animateWithDuration:0.15 animations:^{
                    
                    _nodeImageView.transform = t;
                    
                }];
                
            }];

        }];

    }
}

@end
