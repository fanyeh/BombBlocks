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
    int column;
    int row;
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
    column = 5;
    row = 7;
    moveSize = 57;

    CGRect frame = CGRectMake(0, 0, moveSize*column+2, moveSize*row+2);

    self = [self initWithFrame:frame];
    if (self) {
        // Initialization code
       [self createClassicGameAssetColumn:column andRow:row];

    }
    return self;
}

- (void)createClassicGameAssetColumn:(int)cols andRow:(int)rows
{
//    _assetArray = [[NSMutableArray alloc]init];
    _indexpathArray = [[NSMutableArray alloc]init];

//    CGFloat assetPosX;
//    CGFloat assetPosY;
    
    for (int i = 0 ; i < cols; i ++ ) {
        for (int j = 0 ; j < rows ; j++) {
            
//            GameAsset *asset = [[GameAsset alloc]init];
//
//            assetPosX = i * moveSize+2;
//            assetPosY = j * moveSize+2;

//            if (i%2==1 && j%2==1)
//                [self randomColor:asset];
//            else
//                [asset setAssetType:kAssetTypeEmpty];
            
//            [asset setAssetType:kAssetTypeEmpty];
//            [asset setPosition:CGPointMake(assetPosX, assetPosY)];
//            [self addSubview:asset];
//            [self sendSubviewToBack:asset];
//            [_assetArray addObject:asset];
            
//            if (i == 2 && j == 3) {
//                NSLog(@"center frame %@", NSStringFromCGRect(asset.frame));
//            }
            
            NSIndexPath *assetPath = [NSIndexPath indexPathForRow:j inSection:i];
            [_indexpathArray addObject:assetPath];
            
        }
    }
    
    // Create Asset neighbors
//    for (GameAsset *a in _assetArray) {
//        
//        for (GameAsset *b in _assetArray) {
//            
//            CGRect upper = CGRectOffset(a.frame, 0, -moveSize);
//            CGRect down = CGRectOffset(a.frame, 0, moveSize);
//            CGRect left = CGRectOffset(a.frame, -moveSize, 0);
//            CGRect right = CGRectOffset(a.frame, moveSize, 0);
//            
//            if ([[NSValue valueWithCGRect:b.frame] isEqualToValue:[NSValue valueWithCGRect:upper]]) {
//                [a.neighbors addObject:b];
//            }
//            
//            else if ([[NSValue valueWithCGRect:b.frame] isEqualToValue:[NSValue valueWithCGRect:down]]) {
//                [a.neighbors addObject:b];
//            }
//            
//            else if ([[NSValue valueWithCGRect:b.frame] isEqualToValue:[NSValue valueWithCGRect:left]]) {
//                [a.neighbors addObject:b];
//            }
//            
//            else if ([[NSValue valueWithCGRect:b.frame] isEqualToValue:[NSValue valueWithCGRect:right]]) {
//                [a.neighbors addObject:b];
//            }
//            
//        }
//    }
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
    int randomAsset = arc4random()%5;
    
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
        case 3:
            [asset setAssetType:kAssetTypeGreen];
            break;
    }
}

- (void)hideAllAssets
{
    for (GameAsset *v in _assetArray) {
        v.alpha = 0;
    }
}

@end
