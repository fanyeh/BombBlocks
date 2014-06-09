//
//  GamePad.m
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/5/19.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import "GamePad.h"
#import "GameAsset.h"

@implementation GamePad
{
    NSMutableArray *gameAssets;
    CGFloat moveSize;
}

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
    int column = 13;
    int row = 19;
    moveSize = 23;

    CGRect frame = CGRectMake(0, 0, moveSize*column+4, moveSize*row+4);

    self = [self initWithFrame:frame];
    if (self) {
        // Initialization code
        [self createClassicGameAssetColumn:column andRow:row];
    }
    return self;
}

- (void)createClassicGameAssetColumn:(int)column andRow:(int)row
{
    _assetArray = [[NSMutableArray alloc]init];
    CGFloat assetPosX;
    CGFloat assetPosY;
    
    for (int i = 0 ; i < column; i ++ ) {
        for (int j = 0 ; j < row ; j++) {
            GameAsset *asset = [[GameAsset alloc]init];

            assetPosX = i * moveSize+2;
            assetPosY = j * moveSize+2;
            
            if (i%2==1 && j%2==1)
                [self randomColor:asset];
            else
                [asset setAssetType:kAssetTypeEmpty];
            
            [asset setPosition:CGPointMake(assetPosX, assetPosY)];

            [self addSubview:asset];
            [self sendSubviewToBack:asset];
            [_assetArray addObject:asset];
            
        }
    }
    
    // Create Asset neighbors
    for (GameAsset *a in _assetArray) {
        
        for (GameAsset *b in _assetArray) {
            
            CGRect upper = CGRectOffset(a.frame, 0, -moveSize);
            CGRect down = CGRectOffset(a.frame, 0, moveSize);
            CGRect left = CGRectOffset(a.frame, -moveSize, 0);
            CGRect right = CGRectOffset(a.frame, moveSize, 0);
            
            if ([[NSValue valueWithCGRect:b.frame] isEqualToValue:[NSValue valueWithCGRect:upper]]) {
                [a.neighbors addObject:b];
            }
            
            else if ([[NSValue valueWithCGRect:b.frame] isEqualToValue:[NSValue valueWithCGRect:down]]) {
                [a.neighbors addObject:b];
            }
            
            else if ([[NSValue valueWithCGRect:b.frame] isEqualToValue:[NSValue valueWithCGRect:left]]) {
                [a.neighbors addObject:b];
            }
            
            else if ([[NSValue valueWithCGRect:b.frame] isEqualToValue:[NSValue valueWithCGRect:right]]) {
                [a.neighbors addObject:b];
            }
            
        }
    }
}

- (NSMutableArray *)constructPath:(GameAsset *)asset
{
    NSMutableArray *path = [[NSMutableArray alloc]init];

    while (asset.pathParent != nil) {
        [path insertObject:asset atIndex:0];
        asset = asset.pathParent;
    }
    return path;
}

- (NSMutableArray *)searchPathPlayer:(CGRect)playerFrame enemy:(CGRect)enemyFrame moveDirection:(MoveDirection)moveDirection
{
    GameAsset *enemyAsset;
    GameAsset *playerAsset;
    
    for (GameAsset *a in _assetArray) {
        
        if ([[NSValue valueWithCGRect:a.frame] isEqualToValue:[NSValue valueWithCGRect:playerFrame]]) {
            playerAsset = a;
        }
        
        if ([[NSValue valueWithCGRect:a.frame] isEqualToValue:[NSValue valueWithCGRect:enemyFrame]]) {
            enemyAsset = a;
        }
    }

    NSMutableArray *closedArray  = [[NSMutableArray alloc]init];
    
    NSMutableArray *openArray  = [[NSMutableArray alloc]init];
    
    [openArray addObject:enemyAsset];
    
    enemyAsset.pathParent = nil;
    
    CGRect backwardFrame;
    switch (moveDirection) {
            
        case kMoveDirectionUp:
            backwardFrame = CGRectOffset(enemyFrame, 0, moveSize);
            break;
            
        case kMoveDirectionDown:
            backwardFrame = CGRectOffset(enemyFrame, 0, -moveSize);
            break;
            
        case kMoveDirectionLeft:
            backwardFrame = CGRectOffset(enemyFrame, moveSize, 0);
            break;
            
        case kMoveDirectionRight:
            backwardFrame = CGRectOffset(enemyFrame, -moveSize, 0);
            break;
            
    }

    
    while ([openArray count] > 0) {
        
        GameAsset *nextMoveFrame = [openArray firstObject];
        
        
        if ([[NSValue valueWithCGRect:nextMoveFrame.frame] isEqualToValue:[NSValue valueWithCGRect:playerAsset.frame]]) {
            
            return [self constructPath:playerAsset];
            
        } else {
            
            [closedArray addObject:nextMoveFrame];
            
            
            for (GameAsset *neighbor in nextMoveFrame.neighbors) {
                
                
                if (![closedArray containsObject:neighbor] && ![openArray containsObject:neighbor] && ![self compareFromFrame:neighbor.frame toFrame:backwardFrame]) {
 
                    if (neighbor.gameAssetType == kAssetTypeEmpty) {
                        
                        neighbor.pathParent = nextMoveFrame;
                        [openArray addObject:neighbor];
                        
                    }
                    else if ((neighbor.gameAssetType != kAssetTypeEmpty) && [self compareFromFrame:neighbor.frame toFrame:playerAsset.frame]) {
                        neighbor.pathParent = nextMoveFrame;
                        [openArray addObject:neighbor];
                        
                    }

                }
                
            }
            
        }
        
        [openArray removeObjectAtIndex:0];
    }
    
    return nil;
}

- (BOOL)compareFromFrame:(CGRect)fromFrame toFrame:(CGRect)toFrame
{
    if ([[NSValue valueWithCGRect:fromFrame] isEqualToValue:[NSValue valueWithCGRect:toFrame]])
        return YES;
    else
        return NO;
}

- (void)changeAssetType:(GameAsset *)asset
{
    if ([_assetArray indexOfObject:asset]) {
        
        GameAsset *changeAsset = [_assetArray objectAtIndex:[_assetArray indexOfObject:asset]];
        CGPoint pos = changeAsset.frame.origin;
        [self randomColor:changeAsset];
        [changeAsset setPosition:pos];
    }
}

- (void)resetClassicGamePad
{
    for (GameAsset *a in _assetArray) {
        
        if (a.gameAssetType != kAssetTypeEmpty)
            [self randomColor:a];
    }
}

- (void)randomColor:(GameAsset *)asset
{
    int randomAsset = arc4random()%3;
    
    switch (randomAsset) {
        case 0:
            [asset setAssetType:kAssetTypeBlue];
            break;
        case 1:
            [asset setAssetType:kAssetTypeRed];
            break;
        case 2:
            [asset setAssetType:kAssetTypeYellow];
            break;
    }
}

- (void)setupDotForGameStart:(CGRect)headFrame
{
//    self.alpha = 1;
//    for (SnakeDot *d in _dotArray) {
//        [d changeType];
//        d.alpha = 1;
//        if (CGRectIntersectsRect(d.frame, headFrame))
//            d.hidden = YES;
//    }
}

- (void)hideAllAssets
{
    for (GameAsset *v in _assetArray) {
        v.alpha = 0;
    }
}



@end
