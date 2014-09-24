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
        CGFloat nextNodeSize = 24;
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
        CGFloat imageSize = frame.size.width - 18;
        
        CGRect imageViewRect = CGRectMake((frame.size.width-imageSize)/2,
                                          (frame.size.height-imageSize)/2,
                                          imageSize,
                                          imageSize);
        
        _assetType = assetType;
        _nodeImageView = [[UIImageView alloc]initWithFrame:imageViewRect];
        [self addSubview:_nodeImageView];
        
        scoreLabel = [[CustomLabel alloc]initWithFrame:CGRectMake((self.frame.size.width - 55)/2, 10 , 55, 20) fontSize:17];
        scoreLabel.font = [UIFont fontWithName:@"GeezaPro-Bold" size:17];
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
        self.layer.cornerRadius = 3;//6;
        self.layer.masksToBounds = YES;
        self.layer.borderWidth = 2.5;
        self.layer.borderColor = FontColor.CGColor;
        _hasBomb = NO;
    }
    return self;
}

- (void)setBombWithReminder:(NSInteger)reminder complete:(void(^)(void))completBlock
{
    // Initialization code
    CGFloat imageSize = self.frame.size.width - 10;
    
    CGRect imageViewRect = CGRectMake((self.frame.size.width-imageSize)/2,
                                      (self.frame.size.height-imageSize)/2,
                                      imageSize,
                                      imageSize);
    
    _nodeImageView = [[UIImageView alloc]initWithFrame:imageViewRect];
    
    scoreLabel = [[CustomLabel alloc]initWithFrame:CGRectMake((self.frame.size.width - 55)/2, 10 , 55, 20) fontSize:17];
    scoreLabel.font = [UIFont fontWithName:@"GeezaPro-Bold" size:17];
    [self addSubview:scoreLabel];
    scoreLabel.alpha = 0;
    
    int randAsset;// = arc4random()%6;
    
//    if (reminder > 10)
//        randAsset = arc4random()%6;
//    else if (reminder > 8)
//        randAsset = arc4random()%5;
    if (reminder > 3)
        randAsset = arc4random()%4;
    else
        randAsset = arc4random()%3;
    
    //randAsset = arc4random()%6;

    // Set bomb image
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
    
    CGFloat bombSize = screenWidth * 25/320;
    UIImage *bombImage;
    UIImageView *bombImageView = [[UIImageView alloc]initWithFrame:CGRectMake((imageViewRect.size.width - bombSize)/2,
                                                                              (imageViewRect.size.width - bombSize)/2,
                                                                              bombSize,
                                                                              bombSize)];
    // Set bomb type
    switch (randBomb) {
        case 0:
            _bombType = kBombTypeExplodeHorizontal;
            bombImage = [UIImage imageNamed:@"explodeHorizontal.png"];
            break;
        case 1:
            _bombType = kBombTypeExplodeVertical;
            bombImage = [UIImage imageNamed:@"explodeVertical.png"];
            break;
        case 2:
            _bombType = kBombTypeRandom;
            bombImage = [UIImage imageNamed:@"randomBomb.png"];
            break;
        case 3:
            _bombType = kBombTypeSquareExplode;
            bombImage = [UIImage imageNamed:@"squareExplode.png"];
            break;
        case 4:
            _bombType = kBombTypeExplodeBlock;
            bombImage = [UIImage imageNamed:@"explode.png"];
            break;
    }
    bombImageView.image = bombImage;
    [_nodeImageView addSubview:bombImageView];
    [self addSubview:_nodeImageView];
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
    scoreLabel.frame = CGRectOffset(scoreLabel.frame, 0, -10);
}

-(void)hideScoreLabel
{
    scoreLabel.alpha = 0;
    scoreLabel.frame = CGRectOffset(scoreLabel.frame, 0, 10);
}

-(void)addCountLabel
{
    _hasCount = YES;
    _count = 9;
    CGFloat size = 16;
    CGFloat pos = (self.frame.size.width-size-1);
    countLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(pos,3,size,size) fontSize:size];
    countLabel.text = [NSString stringWithFormat:@"%ld",_count];
    [self addSubview:countLabel];
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
