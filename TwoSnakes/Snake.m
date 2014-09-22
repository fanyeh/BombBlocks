//
//  Snake.m
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/5/1.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import "Snake.h"
#import "GamePad.h"
#import <AVFoundation/AVFoundation.h>
#import "AVAudioPlayer+VolumeFade.h"
#import "MKAppDelegate.h"
#import "CustomLabel.h"

@implementation Snake
{
    NSInteger chain;     // Same color required to form a combo
    CGRect headFrame;
    NSMutableArray *allPatterns;
    NSMutableArray *flipBodyArray;
    SnakeNode *initNode;
    NSInteger totalBombs;
    BOOL isGameover;
    NSMutableArray *bombArray;
    NSURL *currentSongURL;
    MKAppDelegate *appDelegate;
    
    NSMutableArray *rowPatterns;
    NSMutableArray *colPatterns;
    NSMutableArray *squarePatterns;
    NSMutableArray *diaUpPatterns;
    NSMutableArray *diaDownPatterns;
    
    NSInteger bombChain;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithSnakeNode:(SnakeNode *)node gamePad:(GamePad *)gamePad
{
    headFrame = node.frame;
    initNode = node;
    self = [super initWithFrame:headFrame gameAssetType:kAssetTypeBlue];
    if (self) {
        
        appDelegate = [[UIApplication sharedApplication] delegate];
        _gamePad = gamePad;
         chain = 2;
        _xOffset = (headFrame.size.width+2)/1;
        _yOffset = (headFrame.size.height+2)/1;
        _snakeBody = [[NSMutableArray alloc]init];
        _reminder = 3;
        [self newSnake];
        self.tag = 0;
        totalBombs = 0;
        _combos = 0;
        _checkLevel = YES;
    }
    return self;
}

-(void)newSnake
{
    [_snakeBody addObject:self];
    [self setNodeIndexRow:initNode.nodeRow andCol:initNode.nodeColumn];
    [self updateNextNode:self  animation:YES];
}

#pragma mark - Reset Snake

- (void)resetSnake
{
    totalBombs = 0;
    _combos = 0;
    _reminder = 3;
    NSInteger count = [_snakeBody count] - 1;
    currentSongURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"goodbye-dream" ofType:@"mp3"]];
    [self doVolumeFade];
    
    for (int i = 0 ; i < count;i++ ) {
        SnakeNode *n = [_snakeBody lastObject];
        [n removeFromSuperview];
        [_snakeBody removeLastObject];
    }
    SnakeNode *headNode = [_snakeBody firstObject];
    int newInitNodeIndex = arc4random() % [_gamePad.emptyNodeArray count];
    SnakeNode *newInitNode = [_gamePad.emptyNodeArray objectAtIndex:newInitNodeIndex];
    
    
    
    headNode.frame = newInitNode.frame;
    [headNode setNodeIndexRow:newInitNode.nodeRow andCol:newInitNode.nodeColumn];
    [self updateNextNode:headNode animation:NO];
}

- (NodeIndex)updateSnakeNodeIndex:(SnakeNode *)node toFrame:(CGRect)toFrame
{
    NSInteger row = [node nodeRow];
    NSInteger col = [node nodeColumn];
    CGRect fromFrame = node.frame;
    if (toFrame.origin.x > fromFrame.origin.x) {
        // Move to right
        col = col + 1;
    }else if (toFrame.origin.x < fromFrame.origin.x) {
        // Move to left
        col = col - 1;
    } else if (toFrame.origin.y > fromFrame.origin.y) {
        // Move down
        row = row + 1;
    } else if (toFrame.origin.y < fromFrame.origin.y) {
        // Move up
        row = row - 1;
    }
    NodeIndex newNodeIndex;
    newNodeIndex.col = col;
    newNodeIndex.row = row;
    return newNodeIndex;
}

#pragma mark - Directions

- (MoveDirection)headDirection
{
    return self.direction;
}

- (CGRect)getNewPosition:(UIView *)view direction:(MoveDirection)direction
{
    CGRect newPos;
    switch (direction) {
        case kMoveDirectionUp:
            newPos = CGRectOffset(view.frame, 0, -_yOffset);
            break;
        case kMoveDirectionDown:
            newPos = CGRectOffset(view.frame, 0, _yOffset);
            break;
        case kMoveDirectionLeft:
            newPos = CGRectOffset(view.frame, -_xOffset, 0);
            break;
        case kMoveDirectionRight:
            newPos = CGRectOffset(view.frame, _xOffset, 0);
            break;
    }
    return newPos;
}

#pragma mark - Snake Movement

-(void)createBody:(void(^)(void))completBlock
{
    NSMutableArray *vacantNode = [[NSMutableArray alloc]init];
    
    for (SnakeNode *emptyNode in _gamePad.emptyNodeArray) {
        
        if (!emptyNode.hasBomb) {
            
            BOOL hasNode = NO;
            
            for (SnakeNode *bodyNode in _snakeBody) {
                
                if (emptyNode.nodeRow == bodyNode.nodeRow && emptyNode.nodeColumn == bodyNode.nodeColumn) {
                    
                    hasNode = YES;
                    break;
                }
            }
            
            if (!hasNode)
                [vacantNode addObject:emptyNode];
        }
    }

    SnakeNode *bodyNode = [vacantNode objectAtIndex:arc4random() % [vacantNode count]];
    
    SnakeNode *snakeBody = [[SnakeNode alloc]initWithFrame:bodyNode.frame gameAssetType:_nextNode.assetType];
    if (_nextNode.hasCount) {
        
        [snakeBody addCountLabel];
    }
    [snakeBody setNodeIndexRow:bodyNode.nodeRow andCol:bodyNode.nodeColumn];
    snakeBody.direction = [self snakeHead].direction;
    snakeBody.tag = [_snakeBody count];
    snakeBody.nodeImageView.image = _nextNode.nodeImageView.image;
    snakeBody.level = _nextNode.level;
    
    [_snakeBody insertObject:snakeBody atIndex:0];
    [_gamePad addSubview:snakeBody];
    
    // Move next nodes
    [self updateNextNode:_nextNode animation:YES];
    
    // Animation to populate new body
    CGAffineTransform t = snakeBody.transform;
    CGAffineTransform t2 = CGAffineTransformScale(t, 1.2, 1.2);

    snakeBody.transform = CGAffineTransformScale(t, 0.3, 0.3);
    [UIView animateWithDuration:0.15 animations:^{
        
        snakeBody.transform = t2;
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.15 animations:^{
            
            snakeBody.transform = t;
            
        } completion:^(BOOL finished) {
            
            completBlock();
            //[self cancelPattern:completBlock];
            
        }];
        
    }];
}

-(void)levelChecker
{
    if (_checkLevel) {
        if (totalBombs == 125) {
            _reminder = 12;
            [_delegate showLevel:_reminder-2];
        }
        else if (totalBombs == 100) {
            _reminder = 11;
            currentSongURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"cool-rain" ofType:@"mp3"]];
            [self doVolumeFade];
            [_delegate showLevel:_reminder-2];
            [_delegate updateScanTimeInterval];
        }
        else if (totalBombs == 80) {
            _reminder = 10;
            [_delegate showLevel:_reminder-2];
        }
        else if (totalBombs == 60) {
            _reminder = 9;
            currentSongURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"cool-business-model" ofType:@"mp3"]];
            [self doVolumeFade];
            [_delegate showLevel:_reminder-2];
            [_delegate updateScanTimeInterval];
        }
        else if (totalBombs == 45) {
            _reminder = 8;
            [_delegate showLevel:_reminder-2];
        }
        else if (totalBombs == 30) {
            _reminder = 7;
            currentSongURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"cool-space-flight" ofType:@"mp3"]];
            [self doVolumeFade];
            [_delegate showLevel:_reminder-2];
            [_delegate updateScanTimeInterval];
        }
        else if (totalBombs == 20) {
            _reminder = 6;
            [_delegate showLevel:_reminder-2];

        }
        else if (totalBombs == 10) {
            _reminder = 5;
            currentSongURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"flying-forward" ofType:@"mp3"]];
            [self doVolumeFade];
            [_delegate showLevel:_reminder-2];
            [_delegate updateScanTimeInterval];
        }
        else if (totalBombs == 5) {
            _reminder = 4;
            [_delegate showLevel:_reminder-2];
        }
    } 
}

-(void)updateNextNode:(SnakeNode *)node animation:(BOOL)animation
{
    if (node.hasCount)
        [node removeCountLabel];
    
    int randomAsset = arc4random() % _reminder;

    node.level = ceil(randomAsset / 4) + 1;
    
    if (randomAsset > 7 )
        node.level = 1;
    
    switch (randomAsset) {
        case 0:
            node.assetType = kAssetTypeBlue;
            node.nodeImageView.image = [UIImage imageNamed:@"blue.png"];
            node.nodeColor = BlueDotColor;
            break;
        case 1:
            node.assetType = kAssetTypeRed;
            node.nodeImageView.image = [UIImage imageNamed:@"red.png"];
            node.nodeColor = RedDotColor;
            break;
        case 2:
            node.assetType = kAssetTypeGreen;
            node.nodeImageView.image = [UIImage imageNamed:@"green.png"];
            node.nodeColor = GreenDotColor;
            break;
        case 3:
            node.assetType = kAssetTypeYellow;
            node.nodeImageView.image = [UIImage imageNamed:@"yellow.png"];
            node.nodeColor = YellowDotColor;
            break;
        case 4:
            node.assetType = kAssetTypeBlue;
            node.nodeImageView.image = [UIImage imageNamed:@"blue_2.png"];
            node.nodeColor = BlueDotColor;
            break;
        case 5:
            node.assetType = kAssetTypeRed;
            node.nodeImageView.image = [UIImage imageNamed:@"red_2.png"];
            node.nodeColor = RedDotColor;
            break;
        case 6:
            node.assetType = kAssetTypeGreen;
            node.nodeImageView.image = [UIImage imageNamed:@"green_2.png"];
            node.nodeColor = GreenDotColor;
            break;
        case 7:
            node.assetType = kAssetTypeYellow;
            node.nodeImageView.image = [UIImage imageNamed:@"yellow_2.png"];
            node.nodeColor = YellowDotColor;
            break;
        case 8:
            node.assetType = kAssetTypeBlue;
            node.nodeImageView.image = [UIImage imageNamed:@"blue.png"];
            node.nodeColor = BlueDotColor;
            node.hasCount = YES;
            break;
        case 9:
            node.assetType = kAssetTypeRed;
            node.nodeImageView.image = [UIImage imageNamed:@"red.png"];
            node.nodeColor = RedDotColor;
            node.hasCount = YES;
            break;
        case 10:
            node.assetType = kAssetTypeGreen;
            node.nodeImageView.image = [UIImage imageNamed:@"green.png"];
            node.nodeColor = GreenDotColor;
            node.hasCount = YES;
            break;
        case 11:
            node.assetType = kAssetTypeYellow;
            node.nodeImageView.image = [UIImage imageNamed:@"yellow.png"];
            node.nodeColor = YellowDotColor;
            node.hasCount = YES;
            break;
    }
    
    if (animation) {
        
        // Animation to populate new body
        CGAffineTransform t = node.transform;
        node.transform = CGAffineTransformScale(t, 0.5, 0.5);
        [UIView animateWithDuration:0.3 animations:^{
            node.transform = t;
        }];
    }
}

-(void)doVolumeFade
{
    if (appDelegate.audioPlayer.volume > 0.1) {
        
        appDelegate.audioPlayer.volume -=  0.05 ;
        [self performSelector:@selector(doVolumeFade) withObject:nil afterDelay:0.2];
        
    } else {
        // Stop and get the sound ready for playing again
        [appDelegate.audioPlayer stop];
        //appDelegate.audioPlayer.currentTime = 0;
        appDelegate.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:currentSongURL error:nil];
        appDelegate.audioPlayer.numberOfLoops = -1;
        [appDelegate.audioPlayer prepareToPlay];
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"music"]) {
            [appDelegate.audioPlayer play];
            appDelegate.audioPlayer.volume = 0;
            [self volumeFadeIn];
        }
    }
}

- (void)volumeFadeIn
{
    if (appDelegate.audioPlayer.volume < 1) {
        
        appDelegate.audioPlayer.volume +=  0.05;
        [self performSelector:@selector(volumeFadeIn) withObject:nil afterDelay:0.2];
    }
}

- (void)moveAllNodesBySwipe:(MoveDirection)direction complete:(void(^)(void))completBlock
{
    NSSortDescriptor *sortDescriptor;
    switch (direction) {
        case kMoveDirectionDown:
            sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"nodeRow" ascending:NO];
            break;
        case kMoveDirectionUp:
            sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"nodeRow" ascending:YES];
            break;
        case kMoveDirectionLeft:
            sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"nodeColumn" ascending:YES];
            break;
        case kMoveDirectionRight:
            sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"nodeColumn" ascending:NO];
            break;
    }
    NSArray *nodes = [_snakeBody sortedArrayUsingDescriptors:@[sortDescriptor]];
 
    
    [UIView animateWithDuration:0.10 animations:^{
        
        for (SnakeNode *node in nodes) {

            CGRect newPosition;
            NSInteger newCol = node.nodeColumn;
            NSInteger newRow = node.nodeRow;
            
            // Get new position
            switch (direction) {
                case kMoveDirectionDown:
                    newPosition = CGRectOffset(node.frame, 0, _yOffset);
                    newRow++;
                    break;
                case kMoveDirectionUp:
                    newPosition = CGRectOffset(node.frame, 0, -_yOffset);
                    newRow--;
                    break;
                case kMoveDirectionLeft:
                    newPosition = CGRectOffset(node.frame, -_xOffset, 0);
                    newCol--;
                    break;
                case kMoveDirectionRight:
                    newPosition = CGRectOffset(node.frame, _xOffset, 0);
                    newCol++;
                    break;
            }
            
            // If new position does not touch other nodes or game pad boundary , then update node frame to new position so it's node index
            if ([self canMove:newPosition] && node.level == 1) {
                
                node.frame = newPosition;
                [node setNodeIndexRow:newRow andCol:newCol];
                
            }
        }
        
    } completion:^(BOOL finished) {
        
        completBlock();
        //[self cancelPattern:completBlock];

    }];
}

#pragma mark - Patterns



-(void)cancelPattern:(void(^)(void))completBlock
{
    [self checkPatterns];
    bombChain = 0;
    if ([allPatterns count] > 0) {
        
        [_particleView playComboSound];
        
        for (SnakeNode *n in allPatterns) {
            
            [_gamePad showEmptyNodeBorder:n];
            
            // Bomb explode animation
            if (n.hasBomb)
                [self shrinkAnimation:n showExplode:YES];
            else
                [self shrinkAnimation:n showExplode:NO];
        }
        
        [UIView animateWithDuration: 0.5 animations:^{
            
            // Show scores
            for (SnakeNode *n in allPatterns) {
                
                if (n.hasBomb) {
                    
                    bombChain++;
                    [_delegate hideLastTutorial];
                    n.scoreAdder = 50;
                    [n scoreLabelAnimation];
                    
                }
                else if (n.level < 3) {
                    
                    n.scoreAdder = ([allPatterns count]-2) * 5 + 5;
                    [_delegate updateScore:n.scoreAdder];
                    [n scoreLabelAnimation];
                    
                }
            }
            
        } completion:^(BOOL finished) {
            
            [_gamePad resetEmptyNodeBorder];
            
            bombArray = [[NSMutableArray alloc]init];
            
            for (SnakeNode *n in allPatterns) {
                
                if (n.hasBomb) {
                    [bombArray addObject:n];
                    [n removeBomb];
                }
                else if (n.level == 1) {
                    [self explodeBody:n];
                    [n removeFromSuperview];
                }else
                    [self explodeBody:n];
            }
            
            // Remove all combos from snake body
            for (SnakeNode *n in allPatterns)
            {
                if (n.level > 1 && !n.hasBomb)
                    [self reduceLevel:n];
               else
                    [_snakeBody removeObject:n];
            }
            
            if ([bombArray count] > 0)
                [self triggerBomb:completBlock];
            else
                [self cancelPattern:completBlock];
            
        }];
    }
    else  {
        if ([_snakeBody count] == 0)
            [self newSnake];
        completBlock();
    }
}

-(void)triggerBomb:(void(^)(void))completBlock
{
    if ([bombArray count] > 0) {
        SnakeNode *bomb = [bombArray firstObject];
        [_delegate updateScore:bomb.scoreAdder];
        [bombArray removeObject:bomb];
        [self explodeByBomb:bomb complete:completBlock];
    }
    else  {
        if (bombChain > 1)
            [_delegate showBombChain:bombChain];
        if ([_snakeBody count] == 0)
            [self newSnake];
        completBlock();
    }

}

- (void)explodeByBomb:(SnakeNode *)bomb complete:(void(^)(void))completBlock
{
    switch (bomb.bombType)
    {
        case kBombTypeExplodeBlock:
            [self explodeColor:bomb complete:completBlock];
            break;
        case kBombTypeExplodeHorizontal:
            [self explodeRow:bomb complete:completBlock];
            break;
        case kBombTypeExplodeVertical:
            [self explodeCol:bomb complete:completBlock];
            break;
        case kBombTypeSquareExplode:
            [self explodeSquare:bomb complete:completBlock];
            break;
        case kBombTypeRandom:
            [self explodeRandom:bomb complete:completBlock];
            break;
    }
}

- (void)showScoreLabel:(SnakeNode *)node
{
    node.scoreAdder = 5;
    [node scoreLabelAnimation];
    [_delegate updateScore:node.scoreAdder];
}

- (void)completeExplode:(NSMutableArray *)removeNodes
{
    [_gamePad resetEmptyNodeBorder];
    
    for (SnakeNode *node in removeNodes) {
        
        [self explodeBody:node];
        if (node.level == 1) {
            [node removeFromSuperview];
            [_snakeBody removeObject:node];
        }
        else {
            [self reduceLevel:node];
        }
    }
}

- (void)reduceLevel:(SnakeNode *)node
{
    if (node.level == 2) {
        
        node.level = 1;
        [node hideScoreLabel];
        [node.nodeImageView.layer removeAllAnimations];
        switch (node.assetType) {
            case kAssetTypeBlue:
                node.nodeImageView.image = [UIImage imageNamed:@"blue.png"];
                break;
            case kAssetTypeGreen:
                node.nodeImageView.image = [UIImage imageNamed:@"green.png"];
                break;
            case kAssetTypeRed:
                node.nodeImageView.image = [UIImage imageNamed:@"red.png"];
                break;
            case kAssetTypeYellow:
                node.nodeImageView.image = [UIImage imageNamed:@"yellow.png"];
                break;
        }
        
    }  else if (node.level == 3) {
        
        node.level = 2;
        [node hideScoreLabel];
        [node.nodeImageView.layer removeAllAnimations];
        switch (node.assetType) {
            case kAssetTypeBlue:
                node.nodeImageView.image = [UIImage imageNamed:@"blue_2.png"];
                break;
            case kAssetTypeGreen:
                node.nodeImageView.image = [UIImage imageNamed:@"green_2.png"];
                break;
            case kAssetTypeRed:
                node.nodeImageView.image = [UIImage imageNamed:@"red_2.png"];
                break;
            case kAssetTypeYellow:
                node.nodeImageView.image = [UIImage imageNamed:@"yellow_2.png"];
                break;
        }
        
    }
}

- (void)removeBombNode:(SnakeNode *)bombNode complete:(void(^)(void))completBlock
{
    [bombArray addObject:bombNode];

    [UIView animateWithDuration: 0.5 animations:^{
        
        bombNode.scoreAdder = 50;
        [bombNode scoreLabelAnimation];
        
    } completion:^(BOOL finished) {
        
        if (bombNode.bombType == kBombTypeExplodeBlock)
            [self explodeBody:bombNode];
        else if (bombNode.bombType == kBombTypeSquareExplode)
            [self explodeBombSqaureAnimation:bombNode];
        else
            [self explodeBombAnimation:bombNode];
        
        [bombNode removeBomb];
        
        if (completBlock !=nil )
            [self triggerBomb:completBlock];
        
    }];
}

-(void)explodeNextBomb:(NSMutableArray *)triggerBombNodes removeBody:(NSMutableArray *)removedNodes complete:(void(^)(void))completBlock
{
    [self completeExplode:removedNodes];

    if ([triggerBombNodes count] > 0) {
        for (SnakeNode *bombNode in triggerBombNodes){
            
            bombChain++;
            
            if ([bombNode isEqual:[triggerBombNodes lastObject]])
                [self removeBombNode:bombNode complete:completBlock];
            else
                [self removeBombNode:bombNode complete:nil];
        }
    }
    else
        [self triggerBomb:completBlock];
}

#pragma mark - Bomb Types

-(void)explodeColor:(SnakeNode *)bomb complete:(void(^)(void))completBlock
{
    NSMutableArray *removedNode = [[NSMutableArray alloc]init];
    
    NSMutableArray *triggerBombNodes = [[NSMutableArray alloc]init];
    
    for (SnakeNode *bombNode in _gamePad.emptyNodeArray) {
        
        if (bombNode.hasBomb && bombNode.assetType == bomb.assetType) {
            
            [self explodeColorAnimation:bomb target:bombNode];

            [triggerBombNodes addObject:bombNode];
        }
    }

    [UIView animateWithDuration: 0.5 animations:^{
        for (SnakeNode *node in _snakeBody) {
            if (node.assetType ==  bomb.assetType) {
                
                [self explodeColorAnimation:bomb target:node];
                
                [self showScoreLabel:node];
                [removedNode addObject:node];
                [self shrinkAnimation:node showExplode:NO];
                [_particleView explodeColorSound];
            }
        }
    } completion:^(BOOL finished) {
        
        [self explodeNextBomb:triggerBombNodes removeBody:removedNode complete:completBlock];
        
    }];
}

-(void)explodeRow:(SnakeNode *)bomb complete:(void(^)(void))completBlock
{
    NSMutableArray *removedNode = [[NSMutableArray alloc]init];
    NSMutableArray *triggerBombNodes = [[NSMutableArray alloc]init];
    
    for (SnakeNode *bombNode in _gamePad.emptyNodeArray) {
        
        if (bombNode.hasBomb && bombNode.nodeRow == bomb.nodeRow) {
            [triggerBombNodes addObject:bombNode];
        }
    }

    [UIView animateWithDuration: 0.1 animations:^{
        
        for (SnakeNode *node in _snakeBody) {
            if (node.nodeRow ==  bomb.nodeRow) {
                [self showScoreLabel:node];
                [removedNode addObject:node];
            }
        }
        
    } completion:^(BOOL finished) {
        
        [self explodeNextBomb:triggerBombNodes removeBody:removedNode complete:completBlock];
        
    }];
}

-(void)explodeCol:(SnakeNode *)bomb complete:(void(^)(void))completBlock
{
    NSMutableArray *removedNode = [[NSMutableArray alloc]init];
    NSMutableArray *triggerBombNodes = [[NSMutableArray alloc]init];

    for (SnakeNode *bombNode in _gamePad.emptyNodeArray) {
        
        if (bombNode.hasBomb && bombNode.nodeColumn == bomb.nodeColumn) {
            [triggerBombNodes addObject:bombNode];
        }
    }
    
    [UIView animateWithDuration: 0.1 animations:^{
        
        for (SnakeNode *node in _snakeBody) {
            if (node.nodeColumn ==  bomb.nodeColumn) {
                [self showScoreLabel:node];
                [removedNode addObject:node];
            }
        }
        
    } completion:^(BOOL finished) {
        
        [self explodeNextBomb:triggerBombNodes removeBody:removedNode complete:completBlock];

    }];
}

-(void)explodeSquare:(SnakeNode *)bomb complete:(void(^)(void))completBlock
{
    NSMutableArray *removedNode = [[NSMutableArray alloc]init];
    NSMutableArray *triggerBombNodes = [[NSMutableArray alloc]init];
    
    for (SnakeNode *bombNode in _gamePad.emptyNodeArray) {
        
        if ([self checkWithinSquare:bombNode bomb:bomb] && bombNode.hasBomb) {
            [triggerBombNodes addObject:bombNode];
        }
    }
    
    [UIView animateWithDuration: 0.1 animations:^{
        
        for (SnakeNode *node in _snakeBody) {
            
            if ([self checkWithinSquare:node bomb:bomb]) {
                [self showScoreLabel:node];
                [removedNode addObject:node];
            }
        }
        
    } completion:^(BOOL finished) {
        
        [self explodeNextBomb:triggerBombNodes removeBody:removedNode complete:completBlock];

    }];
}

-(void)explodeRandom:(SnakeNode *)bomb complete:(void(^)(void))completBlock
{
    NSMutableArray *emptyNodes = [[NSMutableArray alloc]init];
    
    for (SnakeNode *node in _gamePad.emptyNodeArray) {
        if (!node.hasBomb)
            [emptyNodes addObject:node];
    }

    [_particleView randomBombSound];

    [UIView animateWithDuration:0.3 animations:^{
        
        // Swap block to new position
        for (SnakeNode *node in _snakeBody) {
            
            SnakeNode *newPosNode = [emptyNodes objectAtIndex:arc4random()%emptyNodes.count];
            [node setNodeIndexRow:newPosNode.nodeRow andCol:newPosNode.nodeColumn];
            node.frame = newPosNode.frame;
            [emptyNodes removeObject:newPosNode];
        }
        
    } completion:^(BOOL finished) {
        
        [self triggerBomb:completBlock];
    }];
}

-(BOOL)checkWithinSquare:(SnakeNode *)node bomb:(SnakeNode *)bomb
{
    BOOL remove;
    
    if (node.nodeColumn == bomb.nodeColumn-1 &&  node.nodeRow== bomb.nodeRow-1)
        remove = YES;
    else if (node.nodeColumn == bomb.nodeColumn &&  node.nodeRow== bomb.nodeRow-1)
        remove = YES;
    else if (node.nodeColumn == bomb.nodeColumn+1 &&  node.nodeRow== bomb.nodeRow-1)
        remove = YES;
    
    
    else if (node.nodeColumn == bomb.nodeColumn-1 &&  node.nodeRow== bomb.nodeRow)
        remove = YES;
    else if (node.nodeColumn == bomb.nodeColumn+1 &&  node.nodeRow== bomb.nodeRow)
        remove = YES;
    
    
    else if (node.nodeColumn == bomb.nodeColumn-1 &&  node.nodeRow== bomb.nodeRow+1)
        remove = YES;
    else if (node.nodeColumn == bomb.nodeColumn &&  node.nodeRow== bomb.nodeRow+1)
        remove = YES;
    else if (node.nodeColumn == bomb.nodeColumn+1 &&  node.nodeRow== bomb.nodeRow+1)
        remove = YES;
    else
        remove = NO;
    
    return remove;
}


- (SnakeNode *)snakeHead
{
    return (SnakeNode*)[_snakeBody firstObject];
}

- (SnakeNode *)snakeTail
{
    return (SnakeNode*)[_snakeBody lastObject];
}

#pragma mark - Pattern Check

-(void)checkPatterns
{
    rowPatterns = [[NSMutableArray alloc]init];
    colPatterns = [[NSMutableArray alloc]init];
    squarePatterns = [[NSMutableArray alloc]init];
    diaUpPatterns = [[NSMutableArray alloc]init];
    diaDownPatterns = [[NSMutableArray alloc]init];

    [self colPatternCheck];
    [self rowPatternCheck];
    [self squarePatternCheck];
    [self diagonalDownPatternCheck];
    [self diagonalUpPatternCheck];

    allPatterns = [NSMutableArray arrayWithArray:rowPatterns];
    
    for (id element in colPatterns) {
        if (![allPatterns containsObject:element])
            [allPatterns addObject:element];
    }
    
    for (id element in squarePatterns) {
        if (![allPatterns containsObject:element])
            [allPatterns addObject:element];
    }
    
    for (id element in diaDownPatterns) {
        if (![allPatterns containsObject:element])
            [allPatterns addObject:element];
    }

    for (id element in diaUpPatterns) {
        if (![allPatterns containsObject:element])
            [allPatterns addObject:element];
    }
}

-(void)squarePatternCheck
{
    NSMutableArray *patternArray = [[NSMutableArray alloc]init];
    
    NSMutableArray *bodyArray = [NSMutableArray arrayWithArray:_snakeBody];
    
    [bodyArray removeObjectsInArray:squarePatterns];

    for (SnakeNode *node in bodyArray) {
        
        NSInteger r = [node nodeRow];
        NSInteger c = [node nodeColumn];
        AssetType type = node.assetType;
        
        SnakeNode *node2;
        SnakeNode *node3;
        SnakeNode *node4;
        
        node2 = [self hasPatternRow:r col:c+1 assetType:type];
        node3 = [self hasPatternRow:r+1 col:c assetType:type];
        node4 = [self hasPatternRow:r+1 col:c+1 assetType:type];
        
        if (node2 && node3 && node4) {
            patternArray = [[NSMutableArray alloc]initWithArray: @[node,node2,node3,node4]];
            [squarePatterns addObjectsFromArray:patternArray];
            [self squarePatternCheck];
            break;
        }
        else
        {
            node4 = [self hasPatternRow:r-1 col:c-1 assetType:type];
            
            if (node4)
            {
                node2 = [self hasPatternRow:r col:c-1 assetType:type];
                node3 = [self hasPatternRow:r-1 col:c assetType:type];
                
                if (node2 && node3) {
                    patternArray = [[NSMutableArray alloc]initWithArray: @[node,node2,node3,node4]];
                    [squarePatterns addObjectsFromArray:patternArray];
                    [self squarePatternCheck];
                    break;
                }
            }
        }
    }
}

-(void)colPatternCheck
{
    NSMutableArray *patternArray = [[NSMutableArray alloc]init];
    
    NSMutableArray *bodyArray = [NSMutableArray arrayWithArray:_snakeBody];
    
    [bodyArray removeObjectsInArray:colPatterns];

    for (SnakeNode *node in bodyArray) {
        
        [patternArray removeAllObjects];
        [patternArray addObject:node];

        NSInteger r = [node nodeRow];
        NSInteger c = [node nodeColumn];
        AssetType type = node.assetType;
        
        BOOL hasTop = YES;
        BOOL hasBot = YES;
        int count = 0;
        NSInteger top = r;
        NSInteger bot = r;
        SnakeNode *topNode;
        SnakeNode *botNode;
        
        while (hasBot || hasTop) {
            
            if (hasTop) {
                
                top = top - 1;
                topNode = [self hasPatternRow:top col:c assetType:type];
                
                if (!topNode)
                    hasTop = NO;
                else {
                    [patternArray addObject:topNode];
                    count++;
                }
            }

            if (hasBot) {
                
                bot = bot + 1;
                botNode = [self hasPatternRow:bot col:c assetType:type];
                
                if (!botNode)
                    hasBot = NO;
                else {
                    [patternArray addObject:botNode];
                    count++;
                }
            }
        }
    
        if (count >= chain) {
            _combos++;
            for (SnakeNode *patternNode in patternArray) {
                [colPatterns addObject:patternNode];
            }
            [self colPatternCheck];
            break;
        }
    }
}

-(void)rowPatternCheck
{
    NSMutableArray *patternArray = [[NSMutableArray alloc]init];

    NSMutableArray *bodyArray = [NSMutableArray arrayWithArray:_snakeBody];
    
    [bodyArray removeObjectsInArray:rowPatterns];

    for (SnakeNode *node in bodyArray) {
        
        [patternArray removeAllObjects];
        [patternArray addObject:node];
        
        NSInteger r = [node nodeRow];
        NSInteger c = [node nodeColumn];
        AssetType type = node.assetType;

        BOOL hasRight = YES;
        BOOL hasLeft = YES;

        int count = 0;
        NSInteger right = c;
        NSInteger left = c;
        
        SnakeNode *rightNode;
        SnakeNode *leftNode;
        
        while (hasLeft || hasRight) {
            
            if (hasRight) {
                
                right = right - 1;
                rightNode = [self hasPatternRow:r col:right assetType:type];
                
                if (!rightNode)
                    hasRight = NO;
                else {
                    [patternArray addObject:rightNode];
                    count++;
                }
            }
            
            if (hasLeft) {
                
                left = left + 1;
                leftNode = [self hasPatternRow:r col:left assetType:type];
                
                if (!leftNode)
                    hasLeft = NO;
                else {
                    [patternArray addObject:leftNode];
                    count++;
                }
            }
        }
        
        if (count >= chain) {
            _combos++;
            for (SnakeNode *patternNode in patternArray) {
                [rowPatterns addObject:patternNode];
            }
            [self rowPatternCheck];
            break;
        }
    }
}

-(void)diagonalDownPatternCheck
{
    NSMutableArray *patternArray = [[NSMutableArray alloc]init];
    
    NSMutableArray *bodyArray = [NSMutableArray arrayWithArray:_snakeBody];
    
    [bodyArray removeObjectsInArray:diaDownPatterns];
    
    for (SnakeNode *node in bodyArray) {
        
        [patternArray removeAllObjects];
        [patternArray addObject:node];
        
        NSInteger r = [node nodeRow];
        NSInteger c = [node nodeColumn];
        AssetType type = node.assetType;
        
        BOOL hasUpper = YES;
        BOOL hasDown = YES;

        int count = 0;
        
        NSInteger upper_col = c;
        NSInteger upper_row = r;

        NSInteger down_col = c;
        NSInteger down_row = r;
        
        SnakeNode *upperNode;
        SnakeNode *downNode;
        
        while (hasUpper || hasDown) {

            if (hasDown) {
                down_col = down_col + 1;
                down_row = down_row + 1;
                downNode = [self hasPatternRow:down_row col:down_col assetType:type];
                
                if (!downNode) {
                    hasDown = NO;
                } else {
                    [patternArray addObject:downNode];
                    count++;
                }
            }
            
            if (hasUpper) {
                upper_col = upper_col -1 ;
                upper_row = upper_row - 1;
                upperNode = [self hasPatternRow:upper_row col:upper_col assetType:type];
                
                if (!upperNode) {
                    hasUpper = NO;
                } else {
                    [patternArray addObject:upperNode];
                    count++;
                }
            }
        }
        
        if (count >= chain) {

            _combos++;
            
            for (SnakeNode *patternNode in patternArray) {
                [diaDownPatterns addObject:patternNode];
            }
            [self diagonalDownPatternCheck];
            break;
        }
    }
}

-(void)diagonalUpPatternCheck
{
    NSMutableArray *patternArray = [[NSMutableArray alloc]init];
    
    NSMutableArray *bodyArray = [NSMutableArray arrayWithArray:_snakeBody];
    
    [bodyArray removeObjectsInArray:diaUpPatterns];
    
    for (SnakeNode *node in bodyArray) {
        
        [patternArray removeAllObjects];
        [patternArray addObject:node];
        
        NSInteger r = [node nodeRow];
        NSInteger c = [node nodeColumn];
        AssetType type = node.assetType;
        
        BOOL hasUpper = YES;
        BOOL hasDown = YES;
        
        int count = 0;
        
        NSInteger upper_col = c;
        NSInteger upper_row = r;
        
        NSInteger down_col = c;
        NSInteger down_row = r;
        
        SnakeNode *upperNode;
        SnakeNode *downNode;
        
        while (hasUpper || hasDown) {
            
            if (hasDown) {
                down_col = down_col - 1;
                down_row = down_row + 1;
                downNode = [self hasPatternRow:down_row col:down_col assetType:type];
                
                if (!downNode) {
                    hasDown = NO;
                } else {
                    [patternArray addObject:downNode];
                    count++;
                }
            }
            
            if (hasUpper) {
                upper_col = upper_col + 1 ;
                upper_row = upper_row - 1;
                upperNode = [self hasPatternRow:upper_row col:upper_col assetType:type];
                
                if (!upperNode) {
                    hasUpper = NO;
                } else {
                    [patternArray addObject:upperNode];
                    count++;
                }
            }
        }
        
        if (count >= chain) {
            _combos++;
            for (SnakeNode *patternNode in patternArray) {
                [diaUpPatterns addObject:patternNode];
            }
            [self diagonalUpPatternCheck];
        }
    }
}

- (SnakeNode *)hasPatternRow:(NSInteger)row col:(NSInteger)col assetType:(AssetType)type
{
    for (SnakeNode *node in _snakeBody) {
        
        if ([node nodeRow] == row && [node nodeColumn] == col && node.assetType == type)
            return node;
    }
    
    for (SnakeNode *node in [_gamePad emptyNodeArray]) {
        
        if ([node nodeRow] == row && [node nodeColumn] == col && node.assetType == type && node.hasBomb)
            return node;
    }
    
    return nil;
}

#pragma mark - Combo

-(void)explodeBody:(SnakeNode *)removeBody
{
    if (removeBody.hasBomb) {
        totalBombs++;
        [self levelChecker];
    }
    
    if (removeBody.level == 2)
        
        if (removeBody.assetType == kAssetTypeBlue) {
            // Animation to populate new body
            CGAffineTransform t = removeBody.transform;
            removeBody.transform = CGAffineTransformScale(t, 0.5, 0.5);

            [UIView animateWithDuration:0.4 animations:^{
                
                removeBody.transform = t;

            }];
        }
        else
            [removeBody.layer addAnimation:[self shakeAnimation:0 repeat:NO] forKey:nil];
    else
    {
        // Convert to Sprite kit coordinate
        CGRect bodyFrame = [removeBody convertRect:removeBody.bounds toView:_gamePad];
        bodyFrame.origin.y = _gamePad.frame.size.height - bodyFrame.origin.y;
        CGFloat posX = bodyFrame.origin.x+bodyFrame.size.width/2;
        CGFloat posY = bodyFrame.origin.y-bodyFrame.size.height/2;
        [_particleView newExplosionWithPosX:posX andPosY:posY assetType:removeBody.assetType];
    }
}

-(void)explodeBombAnimation:(SnakeNode *)bomb
{
    totalBombs++;
    [self levelChecker];
    CGRect bodyFrame = bomb.frame;
    CGFloat posX = bodyFrame.origin.x+bodyFrame.size.width/2;
    CGFloat posY = bodyFrame.origin.y+bodyFrame.size.height/2;
    [_gamePad bombExplosionWithPosX:posX andPosY:posY bomb:bomb];
    [_particleView explodeSound];
}

-(void)explodeBombSqaureAnimation:(SnakeNode *)bomb
{
    totalBombs++;
    [self levelChecker];
    CGRect bodyFrame = bomb.frame;
    CGFloat posX = bodyFrame.origin.x+bodyFrame.size.width/2;
    CGFloat posY = bodyFrame.origin.y+bodyFrame.size.height/2;
    [_gamePad bombExplosionSquare:posX andPosY:posY bomb:bomb];
    [_particleView explodeSquareSound];
}

-(void)explodeColorAnimation:(SnakeNode *)bomb target:(SnakeNode *)targetNode
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:bomb.center];
    [path addLineToPoint:targetNode.center];

    CAShapeLayer *pathLayer = [[CAShapeLayer alloc]init];

    pathLayer.frame = bomb.bounds;
    pathLayer.path = path.CGPath;
    pathLayer.strokeColor = bomb.nodeColor.CGColor;
    pathLayer.fillColor = nil;
    pathLayer.lineWidth = 2.5f;
    pathLayer.lineJoin = kCALineJoinBevel;
    pathLayer.opacity = 0.8;
    pathLayer.name = @"beam";
    
    [_gamePad.layer addSublayer:pathLayer];

    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.delegate = _gamePad;
    pathAnimation.duration = 0.3;
    pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    [pathLayer addAnimation:pathAnimation forKey:@"strokeEnd"];
}

#pragma mark - Body Animations

- (void)blinkAnimation:(SnakeNode *)node
{
    node.nodeImageView.alpha = 1.0f;
    
    [UIView animateWithDuration:0.08
                          delay:0.0
                        options:
     
     UIViewAnimationOptionCurveEaseInOut |
     UIViewAnimationOptionRepeat |
     UIViewAnimationOptionAutoreverse |
     UIViewAnimationOptionAllowUserInteraction
     
                     animations:^{
                         
                         node.nodeImageView.alpha = 0.0f;
                     }
                     completion:^(BOOL finished){
                         // Do nothing

                     }];
}

- (void)shrinkAnimation:(SnakeNode *)node showExplode:(BOOL)showExplode
{
    [node.nodeImageView.layer removeAllAnimations];
    CGAffineTransform t = node.nodeImageView.transform;
    
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:
     UIViewAnimationOptionCurveEaseInOut |
     UIViewAnimationOptionRepeat |
     UIViewAnimationOptionAutoreverse
     
                     animations:^{
                         
                         node.nodeImageView.transform = CGAffineTransformScale(t, 0.5, 0.5);
                     
                     }
                     completion:^(BOOL finished){
                         // Do nothing
                         node.nodeImageView.transform = t;
                         
                         if (showExplode) {
                             
                             if (node.bombType == kBombTypeExplodeBlock)
                                 [self explodeBody:node];
                             else if( node.bombType == kBombTypeSquareExplode)
                                 [self explodeBombSqaureAnimation:node];
                             else if( node.bombType == kBombTypeExplodeHorizontal || node.bombType == kBombTypeExplodeVertical)
                                 [self explodeBombAnimation:node];
                         }
                     }];
}

-(CABasicAnimation *)shakeAnimation:(NSInteger)i repeat:(BOOL)repeat
{
    CGFloat toAngle;
    CGFloat fromAngle;
    float repeatCount;
    if (repeat)
        repeatCount = HUGE_VAL;
    else
        repeatCount = 2;
    
    if (i%2 == 0) {
        toAngle = -M_PI/12;
        fromAngle = M_PI/12;
    } else {
        toAngle = M_PI/12;
        fromAngle = -M_PI/12;
    }
    
    CABasicAnimation* anim = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    [anim setToValue:[NSNumber numberWithFloat:toAngle]]; // satrt angle
    [anim setFromValue:[NSNumber numberWithDouble:fromAngle]]; // rotation angle
    [anim setDuration:0.1]; // rotate speed
    [anim setRepeatCount:repeatCount];
    [anim setAutoreverses:YES];
    
    return anim;
}

-(CABasicAnimation *)rotateAnimation:(BOOL)repeat
{
    float repeatCount;
    if (repeat)
        repeatCount = HUGE_VAL;
    else
        repeatCount = 2;
    
    CABasicAnimation* anim = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    [anim setToValue:[NSNumber numberWithFloat:0]]; // satrt angle
    [anim setFromValue:[NSNumber numberWithDouble:2*M_PI]]; // rotation angle
    [anim setDuration:1]; // rotate speed
    [anim setRepeatCount:repeatCount];
    [anim setAutoreverses:NO];
    return anim;
}

#pragma mark - Game Over Animation
- (BOOL)checkIsGameover
{
    NSInteger count = 0;
    for (SnakeNode *n in [_gamePad emptyNodeArray]) {
        if (n.hasBomb)
            count++;
    }
    count = count + [_snakeBody count];
    
    if (count == [_gamePad.emptyNodeArray count])
        return YES;
    else
        return NO;
}

-(void)setGameoverImage
{
    flipBodyArray = [NSMutableArray arrayWithArray:_snakeBody];
    [self flip];
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    if (flipBodyArray != nil) {
        
        SnakeNode *n = [flipBodyArray lastObject];

        switch (n.assetType) {
            case kAssetTypeBlue:
                n.nodeImageView.image = [UIImage imageNamed:@"go_blue.png"];
                break;
            case kAssetTypeRed:
                n.nodeImageView.image = [UIImage imageNamed:@"go_red.png"];
                break;
            case kAssetTypeGreen:
                n.nodeImageView.image = [UIImage imageNamed:@"go_green.png"];
                break;
            case kAssetTypeYellow:
                n.nodeImageView.image = [UIImage imageNamed:@"go_yellow.png"];
                break;
        }
        
        [flipBodyArray removeLastObject];
        
        if ([flipBodyArray count] > 0) {
            
            [self flip];
            
        } else {
            [_delegate showReplayView:totalBombs];
            flipBodyArray = nil;
        }
    }
}

-(void)flip
{
    SnakeNode *n = [flipBodyArray lastObject];
    
    CABasicAnimation* anim = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
    anim.delegate = self;
    [anim setToValue:[NSNumber numberWithFloat:0]]; // satrt angle
    [anim setFromValue:[NSNumber numberWithDouble:M_PI]]; // rotation angle
    [anim setDuration:0.1]; // rotate speed
    [anim setRepeatCount:0];
    [anim setAutoreverses:NO];
    
    [n.nodeImageView.layer addAnimation:anim forKey:nil];
}

#pragma mark - Out of bound

- (BOOL)touchedScreenBounds:(CGRect)newPostion
{
    CGRect screen= _gamePad.bounds;
    CGRect topBound = CGRectMake(0, -2, screen.size.width, 1);
    CGRect botBound = CGRectMake(0, screen.size.height+1, screen.size.width, 1);
    CGRect leftBound = CGRectMake(-2, 0, 1, screen.size.height);
    CGRect rightBound = CGRectMake(screen.size.width+1, 0, 1, screen.size.height);
    
    if (CGRectIntersectsRect(newPostion, topBound))
        return YES;
    else if (CGRectIntersectsRect(newPostion, botBound))
        return YES;
    else if (CGRectIntersectsRect(newPostion, leftBound))
        return YES;
    else if (CGRectIntersectsRect(newPostion, rightBound))
        return YES;
    else
        return NO;
}

-(BOOL)canMove:(CGRect)newPosition
{
    BOOL move = YES;

    // Check if snake head touches body
    for (SnakeNode *v in _snakeBody) {
        // If head touched body , game is over
        if (CGRectIntersectsRect(newPosition, v.frame) && ![v.name isEqualToString:@"name"]) {
            move = NO;
            break;
        }
    }

    // Check if new position touches bomb
    for (SnakeNode *emptyNode in [_gamePad emptyNodeArray]) {
        if (emptyNode.hasBomb && CGRectIntersectsRect(newPosition, emptyNode.frame)) {
            move = NO;
            break;
        }
    }

    // Check if snake head touches boundary
    if ([self touchedScreenBounds:newPosition]) {
        move  = NO;
    }
    
    return move;
}

@end
