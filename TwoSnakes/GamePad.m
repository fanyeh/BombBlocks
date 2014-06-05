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
    CGRect frame = CGRectMake(0, 0, 277, 445);
    self = [self initWithFrame:frame];
    if (self) {
        // Initialization code
        [self createClassicGameAssetColumn:13 andRow:21];
    }
    return self;
}

- (id)initBossGamePad
{
    CGRect frame = CGRectMake(0, 0, 277, 277);
    self = [self initWithFrame:frame];
    if (self) {
        // Initialization code
        [self createClassicGameAssetColumn:13 andRow:13];
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

            assetPosX = i * 21+2;
            assetPosY = j * 21+2;
            
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
            
            CGRect upper = CGRectOffset(a.frame, 0, -21);
            CGRect down = CGRectOffset(a.frame, 0, 21);
            CGRect left = CGRectOffset(a.frame, -21, 0);
            CGRect right = CGRectOffset(a.frame, 21, 0);
            
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
            backwardFrame = CGRectOffset(enemyFrame, 0, 21);
            break;
            
        case kMoveDirectionDown:
            backwardFrame = CGRectOffset(enemyFrame, 0, -21);
            break;
            
        case kMoveDirectionLeft:
            backwardFrame = CGRectOffset(enemyFrame, 21, 0);
            break;
            
        case kMoveDirectionRight:
            backwardFrame = CGRectOffset(enemyFrame, -21, 0);
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
//        case 3:
//            [asset setAssetType:kAssetTypePurple];
//            break;
    }
}

#pragma mark - Puzzle Maker

- (id)initEmptyGamePad
{
    CGRect frame = CGRectMake(0, 0, 315, 441);
    self = [self initWithFrame:frame];
    if (self) {
        // Initialization code
        [self createEmptyPad];        
    }
    return self;
}

- (void)createEmptyPad
{
    _assetArray = [[NSMutableArray alloc]init];
    CGFloat assetPosX;
    CGFloat assetPosY;
    
    for (int i = 0 ; i < 15; i ++ ) {
        for (int j = 0 ; j < 21 ; j++) {
            
            assetPosX = i * 21;
            assetPosY = j * 21;
            
            GameAsset *emptyAsset = [[GameAsset alloc]initWithFrame:CGRectMake(assetPosX, assetPosY, 20, 20)];
            emptyAsset.indexPath = [NSIndexPath indexPathForRow:i inSection:j];
            emptyAsset.layer.borderWidth = 1;
            [self addSubview:emptyAsset];
            [self sendSubviewToBack:emptyAsset];
            [_assetArray addObject:emptyAsset];
        }
    }
}

#pragma mark - Puzzle Trial

- (id)initGamePadWithAsset:(NSMutableArray *)assets
{
    CGRect frame = CGRectMake(2.5, 100, 315, 483);
    self = [self initWithFrame:frame];
    if (self) {
        // Initialization code
        gameAssets = assets;
        _assetArray = [[NSMutableArray alloc]init];

        [self createPadWithAssets];

    }
    return self;
}

- (void)createPadWithAssets
{
    for (GameAsset *a in gameAssets) {
        
        GameAsset *newAsset = [[GameAsset alloc]init];
        [newAsset setAssetType:a.gameAssetType];
        CGFloat assetPosX = a.indexPath.row * 21;
        CGFloat assetPosY = a.indexPath.section * 21;
        
        [newAsset setPosition:CGPointMake(assetPosX, assetPosY)];
        
        //        newAsset.layer.borderWidth = 1;
        [self addSubview:newAsset];
        [self sendSubviewToBack:newAsset];
        
        [_assetArray addObject:newAsset];
    }
}

#pragma mark - Puzzle Play

- (id)initGamePadWithAssetDict:(NSDictionary *)assets
{
    CGRect frame = CGRectMake(2.5, 100, 315, 483);
    self = [self initWithFrame:frame];
    if (self) {
        // Initialization code
        _assetArray = [[NSMutableArray alloc]init];
        
        [self createPadWithAssetsDict:assets];
        
    }
    return self;
}

- (void)createPadWithAssetsDict:(NSDictionary *)assetsDict
{
    NSArray *assets = [assetsDict allValues];
    for (NSDictionary *a in assets) {
        
        GameAsset *newAsset = [[GameAsset alloc]init];
        NSNumber *assetType = [a objectForKey:@"AssetType"];
        NSNumber *row = [a objectForKey:@"Row"];
        NSNumber *column = [a objectForKey:@"Column"];
        
        NSInteger assetPosX = [row integerValue] * 21;
        NSInteger assetPosY = [column integerValue] * 21;
        
        [newAsset setAssetType:[assetType intValue]];
        [newAsset setPosition:CGPointMake(assetPosX, assetPosY)];
        
        [self addSubview:newAsset];
        [self sendSubviewToBack:newAsset];
        
        [_assetArray addObject:newAsset];
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
