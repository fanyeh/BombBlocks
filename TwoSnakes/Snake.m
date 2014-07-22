//
//  Snake.m
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/5/1.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import "Snake.h"
#import "GameAsset.h"
#import "GamePad.h"
#import "ParticleView.h"
#import "SnakeNode.h"

@implementation Snake
{
    NSInteger chain;     // Same color required to form a combo
    CGRect headFrame;
    NSMutableArray *walls;
    AssetType initComboType;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithSnakeHeadDirection:(MoveDirection)direction gamePad:(GamePad *)gamePad headFrame:(CGRect)frame
{
    headFrame = frame;
    self = [self initWithFrame:headFrame];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        [self setNodeIndexRow:4 andCol:3];
        
        // Snake head image
        UIImageView *headImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, headFrame.size.width, headFrame.size.height)];
        headImageView.image = [UIImage imageNamed:@"head.png"];
        headImageView.layer.cornerRadius = headFrame.size.width/4;
        headImageView.transform = CGAffineTransformMakeRotation(-M_PI/2);
        [self addSubview:headImageView];
        
        _gamePad = gamePad;
        _snakeBody = [[NSMutableArray alloc]init];
        [_snakeBody addObject:self];

        _xOffset = (headFrame.size.width+1)/1;
        _yOffset = (headFrame.size.height+1)/1;
        
        self.direction = direction;

        switch (self.direction ) {
                
            case kMoveDirectionLeft:
                    [self snakeHead].transform =  CGAffineTransformMakeRotation(M_PI);
                break;
            case kMoveDirectionUp:
                    [self snakeHead].transform = CGAffineTransformMakeRotation(-M_PI/2);
                break;
            case kMoveDirectionDown:
                    [self snakeHead].transform = CGAffineTransformMakeRotation(M_PI/2);
                break;
            case kMoveDirectionRight:
                break;
        }
        _isRotate = NO;
        chain = 3;
    }
    return self;
}

- (void)updateSnakeNodeIndex:(SnakeNode *)node toFrame:(CGRect)toFrame
{
 
    int row = [node nodeIndexRow];
    int col = [node nodeIndexCol];
    CGRect fromFrame = node.frame;

    if (toFrame.origin.x > fromFrame.origin.x) {
        // Move to right
        col = col + 1;
    }
    else if (toFrame.origin.x < fromFrame.origin.x) {
        // Move to left
        col = col - 1;
    } else if (toFrame.origin.y > fromFrame.origin.y) {
        // Move down
        row = row + 1;
    } else if (toFrame.origin.y < fromFrame.origin.y) {
        // Move up
        row = row - 1;
    }
    
    [node setNodeIndexRow:row andCol:col];
}

#pragma mark - Reset Snake

- (void)resetSnake
{
    [[self snakeHead].layer removeAllAnimations];

    for (SnakeNode *v in _snakeBody) {
        if (v.tag > 0)
            [v removeFromSuperview];
    }
    
    MoveDirection direction = [self headDirection];
    SnakeNode *snakeHead = [self snakeHead];
    snakeHead.frame = headFrame;

    [_snakeBody removeAllObjects];
    
    _xOffset = headFrame.size.width+1;
    _yOffset = headFrame.size.height+1;
    [_snakeBody addObject:snakeHead];
    
    _isRotate = NO;
    
    switch (direction) {
        case kMoveDirectionLeft:
            [self snakeHead].transform =  CGAffineTransformMakeRotation(M_PI);
            break;
        case kMoveDirectionUp:
            [self snakeHead].transform = CGAffineTransformMakeRotation(-M_PI/2);
            break;
        case kMoveDirectionDown:
            [self snakeHead].transform = CGAffineTransformMakeRotation(M_PI/2);
            break;
        case kMoveDirectionRight:
            break;
    }
    
    [self setNodeIndexRow:4 andCol:3];
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

-(void)setTurningNodeBySwipe:(UISwipeGestureRecognizerDirection)swipeDirection
{
    
    _gamePad.userInteractionEnabled = NO;
    MoveDirection direction = [self headDirection];
    
    switch ([self headDirection]) {
        case kMoveDirectionUp:
            if (swipeDirection == UISwipeGestureRecognizerDirectionRight)
                direction = kMoveDirectionRight;
            else if (swipeDirection == UISwipeGestureRecognizerDirectionLeft)
                direction = kMoveDirectionLeft;
            break;
        case kMoveDirectionDown:
            if (swipeDirection == UISwipeGestureRecognizerDirectionRight)
                direction = kMoveDirectionRight;
            else if (swipeDirection == UISwipeGestureRecognizerDirectionLeft)
                direction = kMoveDirectionLeft;
            break;
        case kMoveDirectionLeft:
            if (swipeDirection == UISwipeGestureRecognizerDirectionDown)
                direction = kMoveDirectionDown;
            else if (swipeDirection == UISwipeGestureRecognizerDirectionUp)
                direction = kMoveDirectionUp;
            break;
        case kMoveDirectionRight:
            if (swipeDirection == UISwipeGestureRecognizerDirectionDown)
                direction = kMoveDirectionDown;
            else if (swipeDirection == UISwipeGestureRecognizerDirectionUp)
                direction = kMoveDirectionUp;
            break;
    }
    
    switch ([self headDirection] ) {
        case kMoveDirectionRight:
            if (direction == kMoveDirectionDown) {
                [self snakeHead].transform = CGAffineTransformMakeRotation(M_PI/2); // ok
            }
            else if (direction == kMoveDirectionUp) {
                [self snakeHead].transform = CGAffineTransformMakeRotation(-M_PI/2); // ok
            }
            break;
        case kMoveDirectionLeft:
            if (direction == kMoveDirectionDown) {
                [self snakeHead].transform =  CGAffineTransformMakeRotation(M_PI/2); // ok
            }
            else if (direction == kMoveDirectionUp){
                [self snakeHead].transform = CGAffineTransformMakeRotation(-M_PI/2); // ok
            }
            break;
        case kMoveDirectionUp:
            if (direction == kMoveDirectionLeft){
                [self snakeHead].transform =  CGAffineTransformMakeRotation(-M_PI); // ok
            }
            else if (direction == kMoveDirectionRight){
                [self snakeHead].transform = CGAffineTransformMakeRotation(M_PI_2 - M_PI/2); // ok
            }
            break;
        case kMoveDirectionDown:
            if (direction == kMoveDirectionLeft){
                [self snakeHead].transform = CGAffineTransformMakeRotation(-M_PI); // ok
            }
            
            else if (direction == kMoveDirectionRight){
                [self snakeHead].transform = CGAffineTransformMakeRotation(M_PI_2 - M_PI/2); // ok
            }
            break;
    }
    
    CGRect newPosition = [self getNewPosition:[_snakeBody firstObject] direction:direction];
    
    // Check if snake head touched body or gampad bounds
    
//    if (view.tag == 0 && !_isRotate) {
//        
//        for (UIView *v in _snakeBody) {
//            // If head touched body , game is over
//            if (CGRectIntersectsRect(newPosition, v.frame) && v.tag != 0) {
//                gameIsOver  = YES;
//                break;
//            }
//        }
//        
//        if ([self touchedScreenBounds:newPosition]) {
//            gameIsOver  = YES;
//        }
//        
//        if ([self touchWall:newPosition])
//            gameIsOver = YES;
//    }

    
    
    __block CGRect previousFrame = newPosition;
    __block CGRect currentFrame;
    
    __block MoveDirection previousDirection = direction;
    __block MoveDirection currentDirection;
    
    [UIView animateWithDuration:0.3 animations:^{
        
        for (NSInteger i=0; i < [_snakeBody count];i++) {
            
            SnakeNode *currentBody = [_snakeBody objectAtIndex:i];
            currentFrame = currentBody.frame;
            currentDirection = currentBody.direction;
            
            [self updateSnakeNodeIndex:currentBody toFrame:previousFrame];
            currentBody.frame = previousFrame;
            currentBody.direction = previousDirection;
            
            previousFrame = currentFrame;
            previousDirection = currentDirection;
        }
        
    } completion:^(BOOL finished) {
        
        [self addSnakeBody];
        
    }];
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
    {
        return YES;
    }
    else if (CGRectIntersectsRect(newPostion, botBound))
    {
        return YES;

    }
    else if (CGRectIntersectsRect(newPostion, leftBound))
    {
        return YES;

    }
    else if (CGRectIntersectsRect(newPostion, rightBound))
    {
        return YES;
    }
    else
        return NO;
}

- (void)setWallBounds:(NSMutableArray *)wallbounds
{
    walls = wallbounds;
}

- (BOOL)touchWall:(CGRect)newPosition
{
//    for (GameAsset *asset in walls) {
//        if (asset.gameAssetType == kAssetTypeWall)
//            if (CGRectIntersectsRect(newPosition, asset.frame))
//                return YES;
//    }
    return NO;
}

#pragma mark - Snake Body

- (void)addSnakeBody
{
    CGRect bodyFrame;
    CGRect snakeTailFrame =  [self snakeTail].frame;
    MoveDirection direction = [self snakeTail].direction;
    
    int col= [[self snakeTail]nodeIndexCol];
    int row= [[self snakeTail]nodeIndexRow];

    switch (direction) {
        case kMoveDirectionUp:
            bodyFrame = CGRectOffset(snakeTailFrame, 0, _yOffset);
            row = row + 1;
            break;
        case kMoveDirectionDown:
            bodyFrame = CGRectOffset(snakeTailFrame, 0, -_yOffset);
            row = row - 1;
            break;
        case kMoveDirectionLeft:
            bodyFrame = CGRectOffset(snakeTailFrame, _xOffset, 0);
            col = col + 1;
            break;
        case kMoveDirectionRight:
            bodyFrame = CGRectOffset(snakeTailFrame, -_xOffset, 0);
            col = col - 1;
            break;
    }
    GameAsset *asset = [[GameAsset alloc]init];
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
        case 3:
            [asset setAssetType:kAssetTypeGreen];
            break;
    }
    SnakeNode *snakeBody = [[SnakeNode alloc]initWithFrame:bodyFrame gameAssetType:asset.gameAssetType];
    [snakeBody setNodeIndexRow:row andCol:col];
    CGFloat imageSize = 8;
    UIImageView *bodyImageView = [[UIImageView alloc]initWithFrame:CGRectMake(imageSize/2,
                                                                              imageSize/2,
                                                                              bodyFrame.size.width-imageSize,
                                                                              bodyFrame.size.height-imageSize)];
    switch (asset.gameAssetType) {
        case kAssetTypeGreen:
            bodyImageView.image = [UIImage imageNamed:@"green1.png"];
            snakeBody.nodeColor = GreenDotColor;
            break;
        case kAssetTypeBlue:
            bodyImageView.image = [UIImage imageNamed:@"blue1.png"];
            snakeBody.nodeColor = BlueDotColor;
            break;
        case kAssetTypeRed:
            bodyImageView.image = [UIImage imageNamed:@"red1.png"];
            snakeBody.nodeColor = RedDotColor;
            break;
        case kAssetTypeYellow:
            bodyImageView.image = [UIImage imageNamed:@"yellow1.png"];
            snakeBody.nodeColor = YellowDotColor;
            break;
        case kAssetTypeEmpty:
            break;
    }
    
    [snakeBody addSubview:bodyImageView];
    [_snakeBody addObject:snakeBody];
    [_gamePad addSubview:snakeBody];

    // Animation to populate new body
    CGAffineTransform t = snakeBody.transform;
    snakeBody.transform = CGAffineTransformScale(t, 0.5, 0.5);
    [UIView animateWithDuration:0.5 animations:^{
        
        snakeBody.transform = t;

    } completion:^(BOOL finished) {
        
        [self cancelPattern];
        
    }];
}

-(void)cancelPattern
{
    NSMutableArray *colPatterns = [self colPatternCheck];
    NSMutableArray *rowPatterns = [self rowPatternCheck];
    NSMutableArray *squarePatterns = [self patternCheck:kPatternTypeSquare];
    
    NSMutableArray *allPatterns =[NSMutableArray arrayWithArray:colPatterns];
    for (id element in rowPatterns) {
        if (![allPatterns containsObject:element]) {
            [allPatterns addObject:element];
        }
    }
    
    for (id element in squarePatterns) {
        if (![allPatterns containsObject:element]) {
            [allPatterns addObject:element];
        }
    }
    
    if ([allPatterns count] > 0) {
        
        for (SnakeNode *n in allPatterns) {
            n.backgroundColor = [UIColor whiteColor];
            n.alpha = 0.5;
        }
        
        [UIView animateWithDuration:0.5 animations:^{
            
            for (SnakeNode *n in allPatterns) {
                n.alpha = 0.0;
            }
            
        } completion:^(BOOL finished) {
            
            for (SnakeNode *n in allPatterns) {
                
                [self explodeBody:n];
                [n removeFromSuperview];
            }
            
            [self removeSnakeBodyFromArray:allPatterns];
            
        }];
        
    } else {
        
        _gamePad.userInteractionEnabled = YES;
        
    }
}

-(void)removeSnakeBodyFromArray:(NSMutableArray *)removalArray
{
    SnakeNode *removeBody = [removalArray firstObject];
    __block CGRect previousFrame = removeBody.frame;
    __block CGRect currentFrame;
    __block MoveDirection previousDirection = removeBody.direction;
    __block MoveDirection currentDirection;
    
    NSInteger index = [_snakeBody indexOfObject:removeBody];
    [_snakeBody removeObject:removeBody];
    [removalArray removeObjectAtIndex:0];

    [UIView animateWithDuration:0.3 animations:^{
        
        for (NSInteger i=index; i < [_snakeBody count];i++) {
            
            SnakeNode *currentBody = [_snakeBody objectAtIndex:i];
            currentFrame = currentBody.frame;
            
            [self updateSnakeNodeIndex:currentBody toFrame:previousFrame];
            currentBody.frame = previousFrame;
            currentBody.direction = previousDirection;

            previousFrame = currentFrame;
            previousDirection = currentDirection;
        }
        
    } completion:^(BOOL finished) {
        
        if ([removalArray count] > 0)
            [self removeSnakeBodyFromArray:removalArray];
        else
            [self cancelPattern];
    }];
}

-(NSMutableArray *)patternCheck:(PatternType)patternType
{
    NSMutableArray *patternArray;
    
    for (SnakeNode *node in _snakeBody) {
        
        int r = [node nodeIndexRow];
        int c = [node nodeIndexCol];
        AssetType type = node.assetType;
        
        SnakeNode *node2;
        SnakeNode *node3;
        SnakeNode *node4;
        
        switch (patternType) {
            case kPatternTypeSquare:
                node2 = [self hasPatterRow:r col:c+1 assetType:type];
                node3 = [self hasPatterRow:r+1 col:c assetType:type];
                node4 = [self hasPatterRow:r+1 col:c+1 assetType:type];
                break;
            case kPatternTypeRow:
                return [self colPatternCheck];
                break;
            case kPatternTypeCol:
                return [self rowPatternCheck];
                break;
            case kPatternTypeDiagonalDown:
                
                break;
            case kPatternTypeDiagonalUp:
                
                break;
        }
        
        if ( node2 && node3 && node4) {
            
            patternArray = [[NSMutableArray alloc]initWithArray: @[node,node2,node3,node4]];
            return patternArray;
        }
    }
    return nil;
}

-(NSMutableArray *)colPatternCheck
{
    
    for (SnakeNode *node in _snakeBody) {
        
        NSMutableArray *patternArray = [[NSMutableArray alloc]init];
        [patternArray addObject:node];

        int r = [node nodeIndexRow];
        int c = [node nodeIndexCol];
        AssetType type = node.assetType;
        
        BOOL checkCol = YES;
        int count = 0;

        while (checkCol) {
            r = r+1;
            SnakeNode *n = [self hasPatterRow:r col:c assetType:type];
            if (!n)
                checkCol = NO;
            else {
                [patternArray addObject:n];
                count++;
            }
        }
    
        if (count >= 2) {
            
            return patternArray;
        }
    }
    return nil;
}

-(NSMutableArray *)rowPatternCheck
{
    
    for (SnakeNode *node in _snakeBody) {
        
        NSMutableArray *patternArray = [[NSMutableArray alloc]init];
        [patternArray addObject:node];
        
        int r = [node nodeIndexRow];
        int c = [node nodeIndexCol];
        AssetType type = node.assetType;
        
        BOOL checkCol = YES;
        int count = 0;
        
        while (checkCol) {
            c = c+1;
            SnakeNode *n = [self hasPatterRow:r col:c assetType:type];
            if (!n)
                checkCol = NO;
            else {
                [patternArray addObject:n];
                count++;
            }
        }
        
        if (count >= 2) {
            
            return patternArray;
        }
    }
    return nil;
}

- (SnakeNode *)hasPatterRow:(int)row col:(int)col assetType:(AssetType)type
{
    for (SnakeNode *node in _snakeBody) {
        
        if ([node nodeIndexRow] == row && [node nodeIndexCol] == col && node.assetType == type) {
            
            return node;
        }
    }
    return nil;
}


- (SnakeNode *)snakeHead
{
    return (SnakeNode*)[_snakeBody firstObject];
}

- (SnakeNode *)snakeTail
{
    return (SnakeNode*)[_snakeBody lastObject];
}

- (void)startRotate
{
    _isRotate = YES;
    [[self snakeHead].layer addAnimation:[self wobbleAnimation] forKey:nil];
}

- (void)stopRotate
{
    _isRotate = NO;
    [[self snakeHead].layer removeAllAnimations];
}

#pragma mark - Combo

-(void)explodeBody:(SnakeNode *)removeBody
{
    CGRect bodyFrame = [removeBody convertRect:removeBody.bounds toView:_gamePad];
    bodyFrame.origin.y = _gamePad.frame.size.height - bodyFrame.origin.y;
    CGFloat posX = bodyFrame.origin.x+bodyFrame.size.width/2;
    CGFloat posY = bodyFrame.origin.y-bodyFrame.size.height/2;
    
    [_particleView newExplosionWithPosX:posX
                                andPosY:posY
                               andColor:removeBody.nodeColor];
    
    removeBody.hidden = YES;
}

//- (BOOL)checkCombo:(completeComboCallback)completeBlock
//{
//    NSInteger startIndex = 0;
//    NSInteger endIndex = 0;
//    
//    AssetType repeatType = kAssetTypeEmpty;
//    
//    for (SnakeNode *v in _snakeBody) {
//        
//        if (repeatType != v.assetType) {
//            
//            repeatType = v.assetType;
//            startIndex = [_snakeBody indexOfObject:v];
//            endIndex = startIndex;
//            
//        }
//        else {
//            
//            endIndex = [_snakeBody indexOfObject:v];
//        }
//
//        if (endIndex - startIndex == chain) {
//            
//            initComboType = repeatType;
//            
//            // Shake snake head
//            if (!_isRotate)
//                [self startRotate];
//
//            [self comboAnimationStartIndex:startIndex
//                                  endIndex:endIndex
//                             completeBlock:completeBlock
//                                assetType:repeatType
//                                otherCombo:NO];
//            
//            return YES;
//        }
//    }
//    completeBlock(kAssetTypeEmpty,NO);
//    return NO;
//}

// Single body color check
//- (void)cancelSnakeBodyByType:(AssetType)assetType complete:(completeComboCallback)completeBlock
//{
//    BOOL completeCheck = YES;
//    
//    // Remove each body with same color
//    for (SnakeNode *v in _snakeBody) {
//        if (v.assetType == assetType) {
//            
//            // Remove same color body from initial combo
//            NSInteger index = [_snakeBody indexOfObject:v];
//            
//            // Remove snake body with color same as combo
//            [self removeSnakeBodyByIndex:index andAssetType:v.assetType complete:completeBlock];
//            
//            completeCheck = NO;
//            break;
//        }
//    }
//    
//    // Check if there is other combos
//    if (completeCheck)
//        [self otherCombo:completeBlock];
//}

// Single body removal
//-(void)removeSnakeBodyByIndex:(NSInteger)index andAssetType:(AssetType)assetType complete:(completeComboCallback)completeBlock
//{
//    SnakeNode *removeBody = [_snakeBody objectAtIndex:index];
//    __block CGRect previousFrame = removeBody.frame;
//    __block CGRect currentFrame;
//    
//    if (!removeBody.isHidden)
//        [self explodeBody:removeBody];
//    
//    [removeBody removeFromSuperview];
//    
//    [_snakeBody removeObjectAtIndex:index];
//    
//
//    [UIView animateWithDuration:0.3 animations:^{
//        
//        for (NSInteger i=index; i < [_snakeBody count];i++) {
//
//            UIView *currentBody = [_snakeBody objectAtIndex:i];
//            currentFrame = currentBody.frame;
//            currentBody.frame = previousFrame;
//            previousFrame = currentFrame;
//        }
//        
//    } completion:^(BOOL finished) {
//        
//        //[self cancelSnakeBodyByType:assetType complete:completeBlock];
//        
//    }];
//}


//-(BOOL)otherCombo:(completeComboCallback)completeBlock
//{
//    AssetType repeatAsset = kAssetTypeEmpty;
//    NSInteger startIndex = 0;
//    NSInteger endIndex = 0;
//    BOOL hasCombo = NO;
//    
//    for (SnakeNode *v in _snakeBody) {
//        
//        if (repeatAsset != v.assetType) {
//            
//            if (hasCombo) {
//                // Invalidate timer if there combo
//                [self comboAnimationStartIndex:startIndex
//                                      endIndex:endIndex
//                                 completeBlock:completeBlock
//                                    assetType:repeatAsset
//                                    otherCombo:YES];
//                
//                return YES;
//                
//            }
//            else {
//                repeatAsset = v.assetType;
//                startIndex = [_snakeBody indexOfObject:v];
//                endIndex = startIndex;
//            }
//            
//        } else {
//            
//            endIndex = [_snakeBody indexOfObject:v];
//            
//            // More than chain
//            if (endIndex - startIndex == chain) {
//                
//                hasCombo = YES;
//            }
//            
//            if ([v isEqual:[_snakeBody lastObject]] && hasCombo) {
//                
//                [self comboAnimationStartIndex:startIndex
//                                      endIndex:endIndex
//                                 completeBlock:completeBlock
//                                     assetType:repeatAsset
//                                    otherCombo:YES];
//                return YES;
//                
//            }
//        }
//    }
//    // If no other combo call the complete block
//    completeBlock(initComboType,YES);
//    return NO;
//}

//-(void)removeSnakeBodyByRangeStart:(NSInteger)start andRange:(NSInteger)range complete:(completeComboCallback)completeBlock
//{
//    if (range == 0) {
//
//        [self otherCombo:completeBlock];
//        
//    } else {
//
//        SnakeNode *removeBody = [_snakeBody objectAtIndex:start];
//        
//        if (!removeBody.isHidden)
//            [self explodeBody:removeBody];
//        
//        __block CGRect previousFrame = removeBody.frame;
//        __block CGRect currentFrame;
//        [removeBody removeFromSuperview];
//
//        [self.snakeBody removeObjectAtIndex:start];
//
//        [UIView animateWithDuration:0.3 animations:^{
//            
//            for (NSInteger i=start; i < [_snakeBody count];i++) {
//                
//                UIView *currentBody = [_snakeBody objectAtIndex:i];
//                currentFrame = currentBody.frame;
//                
//                
//                currentBody.frame = previousFrame;
//                previousFrame = currentFrame;
//            }
//            
//        } completion:^(BOOL finished) {
//
//            [self removeSnakeBodyByRangeStart:start andRange:range-1 complete:completeBlock];
//
//        }];
//
//    }
//}

//- (void)comboAnimationStartIndex:(NSInteger)start endIndex:(NSInteger)end
//                   completeBlock:(completeComboCallback)completeBlock
//                      assetType:(AssetType)assetType
//                      otherCombo:(BOOL)other
//{
//    
//    _combos++;
//    
//    // Apply shake animation
//    for (NSInteger i = start ; i < end +1 ; i ++) {
//        
//        UIView *u = _snakeBody[i];
//        [u.layer addAnimation:[self bodyAnimation:i] forKey:nil];
//        
//    }
//    
//    // Blink snake head
//    [UIView animateWithDuration:0.5 animations:^{
//        
//        self.snakeHead.alpha = 0.0f;
//
//    } completion:^(BOOL finished) {
//        
//        self.snakeHead.alpha = 1.0f;
//        
//        // Remove all shake animation
//        for (NSInteger i = start ; i < end +1 ; i ++) {
//            UIView *u = _snakeBody[i];
//            [u.layer removeAllAnimations];
//        }
//        
//        if (other)
//            [self removeSnakeBodyByRangeStart:start andRange:(end - start) + 1 complete:completeBlock];
//        
//        else {
//            
//            // Show explode animation
//            // Check if these bodies overlapped with turning node , if yes remove turning node
//            // Remove body from snake array
//            for (NSInteger i = 0 ; i < chain+1 ; i ++) {
//                
//                [self explodeBody:[_snakeBody lastObject]];
//                [[_snakeBody lastObject] removeFromSuperview];
//                [_snakeBody removeLastObject];
//            }
//            
//            [self cancelSnakeBodyByType:assetType complete:completeBlock];
//            
//        }
//    }];
//}

#pragma mark - Body Animations

- (void)startBlinkAnimation
{
    self.snakeHead.alpha = 1.0f;
    
    [UIView animateWithDuration:0.12
                          delay:0.0
                        options:
     
     UIViewAnimationOptionCurveEaseInOut |
     UIViewAnimationOptionRepeat |
     UIViewAnimationOptionAutoreverse |
     UIViewAnimationOptionAllowUserInteraction
     
                     animations:^{
                         
                         self.snakeHead.alpha = 0.0f;
                     }
                     completion:^(BOOL finished){
                         // Do nothing
                     }];
}

-(void)stopBlinkAnimation
{
    [UIView animateWithDuration:0.12
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut |
     UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.snakeHead.alpha = 1.0f;
                     }
                     completion:^(BOOL finished){
                         // Do nothing
                     }];
}

-(CABasicAnimation *)bodyAnimation:(NSInteger)i
{
    CGFloat toAngle;
    CGFloat fromAngle;
    
    if (i%2 == 0) {
        toAngle = -M_PI/6;
        fromAngle = M_PI/6;
    } else {
        toAngle = M_PI/6;
        fromAngle = -M_PI/6;
    }
    
    CABasicAnimation* anim = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    [anim setToValue:[NSNumber numberWithFloat:toAngle]]; // satrt angle
    [anim setFromValue:[NSNumber numberWithDouble:fromAngle]]; // rotation angle
    [anim setDuration:0.1]; // rotate speed
    [anim setRepeatCount:HUGE_VAL];
    [anim setAutoreverses:YES];
    
    return anim;
}

-(CABasicAnimation *)stunAnimation:(NSInteger)i
{
    CGFloat toAngle;
    CGFloat fromAngle;
    
    if (i%2 == 0) {
        toAngle = -M_PI/24;
        fromAngle = M_PI/24;
    } else {
        toAngle = M_PI/24;
        fromAngle = -M_PI/24;
    }
    
    CABasicAnimation* anim = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    [anim setToValue:[NSNumber numberWithFloat:toAngle]]; // satrt angle
    [anim setFromValue:[NSNumber numberWithDouble:fromAngle]]; // rotation angle
    [anim setDuration:0.1]; // rotate speed
    [anim setRepeatCount:HUGE_VAL];
    [anim setAutoreverses:YES];
    
    return anim;
}

-(CABasicAnimation *)wobbleAnimation
{
    CGFloat startAngle;
    CGFloat endAngle;
    
    switch ([self headDirection] ) {
        case kMoveDirectionRight:
            
            startAngle = -M_PI/6;
            endAngle = M_PI/6;
            
            break;
        case kMoveDirectionLeft:
            
            startAngle = M_PI-M_PI/6;
            endAngle = M_PI+M_PI/6;

            break;
        case kMoveDirectionUp:
            
            startAngle = -M_PI/2+M_PI/6;
            endAngle = -M_PI/2-M_PI/6;
 
            break;
        case kMoveDirectionDown:
            
            startAngle = M_PI/2-M_PI/6;
            endAngle = M_PI/2+M_PI/6;
            
            break;
    }

    CABasicAnimation* anim = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    [anim setToValue:[NSNumber numberWithFloat:startAngle]]; // satrt angle
    [anim setFromValue:[NSNumber numberWithDouble:endAngle]]; // rotation angle
    [anim setDuration:0.25]; // rotate speed
    [anim setRepeatCount:HUGE_VAL];
    [anim setAutoreverses:YES];
    return anim;
}

#pragma mark - Game Over Animation

-(CABasicAnimation *)gameOverAnimation
{
    CABasicAnimation* anim = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    [anim setToValue:[NSNumber numberWithFloat:0]]; // satrt angle
    [anim setFromValue:[NSNumber numberWithDouble:2*M_PI]]; // rotation angle
    [anim setDuration:1]; // rotate speed
    [anim setRepeatCount:HUGE_VAL];
    [anim setAutoreverses:NO];
    return anim;
}

- (void)gameOver
{
    [[self snakeHead].layer addAnimation:[self gameOverAnimation] forKey:nil];
}

@end
