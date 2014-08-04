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
    CGFloat border;
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
        border = 4;
        self.layer.borderColor = FontColor.CGColor;
        self.layer.borderWidth = border;
        //self.backgroundColor = [UIColor whiteColor];
        [self setNodeIndexRow:4 andCol:3];
        self.name = @"head";
        
        // Snake head image
        CGFloat headOffset = 4;
        UIImageView *headImageView = [[UIImageView alloc]initWithFrame:CGRectMake(headOffset, headOffset, headFrame.size.width-headOffset*2, headFrame.size.height-headOffset*2)];
        headImageView.image = [UIImage imageNamed:@"head.png"];
        //headImageView.layer.cornerRadius = headFrame.size.width/4;
        headImageView.transform = CGAffineTransformMakeRotation(-M_PI/2);
        //headImageView.backgroundColor = [UIColor whiteColor];
        [self addSubview:headImageView];
        
        //[headImageView.layer addAnimation:[self gameOverAnimation] forKey:nil];
        
        _gamePad = gamePad;
        _snakeBody = [[NSMutableArray alloc]init];
        [_snakeBody addObject:self];

        _xOffset = (headFrame.size.width+2)/1;
        _yOffset = (headFrame.size.height+2)/1;
        
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
        chain = 2;
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
        if (![v.name isEqualToString:@"head"])
            [v removeFromSuperview];
    }
    
    MoveDirection direction = [self headDirection];
    SnakeNode *snakeHead = [self snakeHead];
    snakeHead.frame = headFrame;

    [_snakeBody removeAllObjects];
    
    _xOffset = headFrame.size.width+1;
    _yOffset = headFrame.size.height+1;
    [_snakeBody addObject:snakeHead];
    
    
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

#pragma mark - Snake Movement



-(void)swipeToMove:(UISwipeGestureRecognizerDirection)swipeDirection complete:(void(^)(void))completBlock
{
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
    
//    switch ([self headDirection] ) {
//        case kMoveDirectionRight:
//            if (direction == kMoveDirectionDown) {
//                [self snakeHead].transform = CGAffineTransformMakeRotation(M_PI/2); // ok
//            }
//            else if (direction == kMoveDirectionUp) {
//                [self snakeHead].transform = CGAffineTransformMakeRotation(-M_PI/2); // ok
//            }
//            break;
//        case kMoveDirectionLeft:
//            if (direction == kMoveDirectionDown) {
//                [self snakeHead].transform =  CGAffineTransformMakeRotation(M_PI/2); // ok
//            }
//            else if (direction == kMoveDirectionUp){
//                [self snakeHead].transform = CGAffineTransformMakeRotation(-M_PI/2); // ok
//            }
//            break;
//        case kMoveDirectionUp:
//            if (direction == kMoveDirectionLeft){
//                [self snakeHead].transform =  CGAffineTransformMakeRotation(-M_PI); // ok
//            }
//            else if (direction == kMoveDirectionRight){
//                [self snakeHead].transform = CGAffineTransformMakeRotation(M_PI_2 - M_PI/2); // ok
//            }
//            break;
//        case kMoveDirectionDown:
//            if (direction == kMoveDirectionLeft){
//                [self snakeHead].transform = CGAffineTransformMakeRotation(-M_PI); // ok
//            }
//            
//            else if (direction == kMoveDirectionRight){
//                [self snakeHead].transform = CGAffineTransformMakeRotation(M_PI_2 - M_PI/2); // ok
//            }
//            break;
//    }
    
    CGRect newPosition = [self getNewPosition:[_snakeBody firstObject] direction:direction];
    
    BOOL move = YES;
    
    // Check if snake head touches body
    for (SnakeNode *v in _snakeBody) {
        // If head touched body , game is over
        if (CGRectIntersectsRect(newPosition, v.frame) && ![v.name isEqualToString:@"name"]) {
            move = NO;
            break;
        }
    }
    
    // Check if snake head touches boundary
    if ([self touchedScreenBounds:newPosition]) {
        move  = NO;
    }
    
    if (move) {
        
        CGRect oldPosition = [self snakeHead].frame;
        NodeIndex oldNodePath = [self snakeHead].nodePath;
        
        [UIView animateWithDuration:0.1 animations:^{
            
            [self updateSnakeNodeIndex:[self snakeHead] toFrame:newPosition];
            [self snakeHead].frame = newPosition;
            [self snakeHead].direction = direction;
    
            
        } completion:^(BOOL finished) {
            
            SnakeNode *nextNode = [_comingNodeArray firstObject];
            SnakeNode *nextNode2 = [_comingNodeArray objectAtIndex:1];
            SnakeNode *nextNode3 = [_comingNodeArray objectAtIndex:2];

            [self addSnakeBodyAfterHead:nextNode.assetType position:oldPosition nodePath:oldNodePath complete:completBlock];
            
            CGRect firstNodeFrame = nextNode.frame;
            CGRect secondNodeFrame = nextNode2.frame;
            CGAffineTransform nodeT = nextNode.transform;
            
            
            // Shrink first node
            [UIView animateWithDuration:0.2 animations:^{
                
                nextNode.transform = CGAffineTransformScale(nextNode.transform, 0, 0);
                
            } completion:^(BOOL finished) {
                
                nextNode.alpha = 0;
                nextNode.transform = nodeT;
                nextNode.frame = nextNode3.frame;
                
                // Move second node
                [UIView animateWithDuration:0.15 animations:^{
                    
                    nextNode2.frame = firstNodeFrame;
                    
                } completion:^(BOOL finished) {
                    
                    // Move third node
                    [UIView animateWithDuration:0.15 animations:^{
                        
                        nextNode3.frame = secondNodeFrame;
                        nextNode.transform = CGAffineTransformScale(nextNode.transform, 0, 0);
                        
                    } completion:^(BOOL finished) {
                        
                        int randomAsset = arc4random()%4;
                        switch (randomAsset) {
                            case 0:
                                nextNode.assetType = kAssetTypeBlue;
                                nextNode.nodeImageView.image = [UIImage imageNamed:@"blue.png"];
                                break;
                            case 1:
                                nextNode.assetType = kAssetTypeRed;
                                nextNode.nodeImageView.image = [UIImage imageNamed:@"red.png"];
                                break;
                            case 2:
                                nextNode.assetType = kAssetTypeGreen;
                                nextNode.nodeImageView.image = [UIImage imageNamed:@"green.png"];
                                break;
                            case 3:
                                nextNode.assetType = kAssetTypeYellow;
                                nextNode.nodeImageView.image = [UIImage imageNamed:@"yellow.png"];
                                break;
                            case 4:
                                nextNode.assetType = kAssetTypePurple;
                                nextNode.nodeImageView.image = [UIImage imageNamed:@"purple.png"];

                                break;
                        }
  
                        [UIView animateWithDuration:0.2 animations:^{
                            
                            nextNode.transform = nodeT;
                            nextNode.alpha = 1;
                            
                        } completion:^(BOOL finished) {
          
                            [_comingNodeArray addObject:nextNode];
                            [_comingNodeArray removeObjectAtIndex:0];
                            _gamePad.userInteractionEnabled = YES;

                            
                        }];
                        
                    }];

                }];
                
            }];
            
        }];
        
    } else {
        
        completBlock();
        _gamePad.userInteractionEnabled = YES;
    }
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

#pragma mark - Snake Body

- (void)addSnakeBodyAfterHead:(AssetType)assetType position:(CGRect)position nodePath:(NodeIndex)nodePath complete:(void(^)(void))completBlock
{
    CGFloat imageSize = 18;
    SnakeNode *snakeBody = [[SnakeNode alloc]initWithFrame:position gameAssetType:assetType imageFrame:CGRectMake(imageSize/2,
                                                                                                                  imageSize/2,
                                                                                                                  position.size.width-imageSize,
                                                                                                                  position.size.height-imageSize)];
    snakeBody.layer.borderColor = FontColor.CGColor;
    snakeBody.layer.borderWidth = border;
    snakeBody.nodePath = nodePath;
    snakeBody.direction = [self snakeHead].direction;

    switch (assetType) {
        case kAssetTypeGreen:
            snakeBody.nodeColor = GreenDotColor;
            snakeBody.nodeImageView.image = [UIImage imageNamed:@"green.png"];

            break;
        case kAssetTypeBlue:
            snakeBody.nodeColor = BlueDotColor;
            snakeBody.nodeImageView.image = [UIImage imageNamed:@"blue.png"];

            break;
        case kAssetTypeRed:
            snakeBody.nodeColor = RedDotColor;
            snakeBody.nodeImageView.image = [UIImage imageNamed:@"red.png"];

            break;
        case kAssetTypeYellow:
            snakeBody.nodeColor = YellowDotColor;
            snakeBody.nodeImageView.image = [UIImage imageNamed:@"yellow.png"];

            break;
        case kAssetTypePurple:
            snakeBody.nodeColor = PurpleDotColor;
            snakeBody.nodeImageView.image = [UIImage imageNamed:@"purple.png"];

            break;
        case kAssetTypeEmpty:
            break;
    }
    
    //[snakeBody addSubview:bodyImageView];

    
    if([_snakeBody count] == 1)
        [_snakeBody addObject:snakeBody];
    else
        [_snakeBody insertObject:snakeBody atIndex:1];
    
    [_gamePad addSubview:snakeBody];
    
    // Animation to populate new body
    CGAffineTransform t = snakeBody.transform;
    snakeBody.transform = CGAffineTransformScale(t, 0.5, 0.5);
    [UIView animateWithDuration:0.2 animations:^{
        
        snakeBody.transform = t;
        
    } completion:^(BOOL finished) {
        
        [self cancelPattern:completBlock];
        
    }];
}

-(void)cancelPattern:(void(^)(void))completBlock
{
    NSMutableArray *colPatterns = [self colPatternCheck];
    NSMutableArray *rowPatterns = [self rowPatternCheck];
    NSMutableArray *squarePatterns = [self patternCheck:kPatternTypeSquare];
    NSMutableArray *diaDownPatterns = [self patternCheck:kPatternTypeDiagonalDown];
    NSMutableArray *diaUpPatterns = [self patternCheck:kPatternTypeDiagonalUp];
    NSMutableArray *crossPatterns = [self patternCheck:kPatternTypeCross];
    NSMutableArray *xPatterns = [self patternCheck:kPatternTypeX];
    NSMutableArray *hallowSquarePatterns = [self patternCheck:kPatternTypeHallowSquare];


    
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
    
    for (id element in diaDownPatterns) {
        if (![allPatterns containsObject:element]) {
            [allPatterns addObject:element];
        }
    }
    
    for (id element in diaUpPatterns) {
        if (![allPatterns containsObject:element]) {
            [allPatterns addObject:element];
        }
    }
    
    for (id element in crossPatterns) {
        if (![allPatterns containsObject:element]) {
            [allPatterns addObject:element];
        }
    }
    
    for (id element in xPatterns) {
        if (![allPatterns containsObject:element]) {
            [allPatterns addObject:element];
        }
    }
    
    for (id element in hallowSquarePatterns) {
        if (![allPatterns containsObject:element]) {
            [allPatterns addObject:element];
        }
    }
    
    
    if ([allPatterns count] > 0) {
        
        //[[self snakeHead].layer addAnimation:[self wobbleAnimation] forKey:nil];
        
        for (SnakeNode *n in allPatterns) {
            
            n.alpha = 0.6;
            
            switch (n.assetType) {
                case kAssetTypeBlue:
                    [self startBlinkAnimation:n];


                    break;
                case kAssetTypeYellow:
                    [n.nodeImageView.layer addAnimation:[self shakeAnimation:[allPatterns indexOfObject:n]] forKey:nil];

                    break;
                case kAssetTypeRed:
                    [n.nodeImageView.layer addAnimation:[self rotateAnimation] forKey:nil];

                    
                    break;
                case kAssetTypeGreen:
                    [n.nodeImageView.layer addAnimation:[self shakeAnimation:[allPatterns indexOfObject:n]] forKey:nil];

                    break;
            }
        }
        
        [UIView animateWithDuration: 0.8 animations:^{
            
            for (SnakeNode *n in allPatterns) {
                
                n.layer.borderColor = n.nodeColor.CGColor;
                n.alpha = 1.0;
            }
            
        } completion:^(BOOL finished) {
            
            for (SnakeNode *n in allPatterns) {
                
                [self explodeBody:n];
                [n removeFromSuperview];
            }
            
            [self removeSnakeBodyFromArray:allPatterns complete:completBlock];
            
        }];
    }
    else {
        
        completBlock();
        //[[self snakeHead].layer removeAllAnimations];
    }
}

-(void)removeSnakeBodyFromArray:(NSMutableArray *)removalArray complete:(void(^)(void))completBlock
{
    // Get 1st objects from removal pattern array
    SnakeNode *removeBody = [removalArray firstObject];
    
    // Get directio and frame of removal body
    __block CGRect previousFrame = removeBody.frame;
    __block CGRect currentFrame;
    __block MoveDirection previousDirection = removeBody.direction;
    __block MoveDirection currentDirection;
    __block NodeIndex previousNodePath = removeBody.nodePath;
    __block NodeIndex currentNodePath;
    
    // Get index of removal body
    NSInteger index = [_snakeBody indexOfObject:removeBody];
    
    // Remove body from snake body array
    [_snakeBody removeObject:removeBody];
    
    // Remove pattern from removal pattern array
    [removalArray removeObjectAtIndex:0];

    // Start pattern moving animation
    [UIView animateWithDuration:0.3 animations:^{
        
        for (NSInteger i=index; i < [_snakeBody count];i++) {
            
            SnakeNode *currentBody = [_snakeBody objectAtIndex:i];
            currentFrame = currentBody.frame;
            currentDirection = currentBody.direction;
            currentNodePath = currentBody.nodePath;
            
            // Set node indexpath based on move to frame position

            currentBody.frame = previousFrame;
            currentBody.direction = previousDirection;
            currentBody.nodePath = previousNodePath;

            previousFrame = currentFrame;
            previousDirection = currentDirection;
            previousNodePath = currentNodePath;
        }
        
    } completion:^(BOOL finished) {
        
        // Loop pattern removal till count = 0
        if ([removalArray count] > 0)
            [self removeSnakeBodyFromArray:removalArray complete:completBlock];
        else // Check if there are more combos
            [self cancelPattern:completBlock];
    }];
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
                node2 = [self hasPatternRow:r col:c+1 assetType:type];
                node3 = [self hasPatternRow:r+1 col:c assetType:type];
                node4 = [self hasPatternRow:r+1 col:c+1 assetType:type];
                
                if ( node2 && node3 && node4) {
                    
                    patternArray = [[NSMutableArray alloc]initWithArray: @[node,node2,node3,node4]];
                    return patternArray;
                }
                
                break;
            case kPatternTypeRow:
                return [self colPatternCheck];
                break;
            case kPatternTypeCol:
                return [self rowPatternCheck];
                break;
            case kPatternTypeDiagonalDown:
                return [self diagonalDownPatternCheck];

                break;
            case kPatternTypeDiagonalUp:
                return [self diagonalUpPatternCheck];
                break;
            case kPatternTypeCross:
                return [self crossPatternCheck];
                break;
            case kPatternTypeX:
                return [self xPatternCheck];
                break;
            case kPatternTypeHallowSquare:
                return [self hallowSquarePatternCheck];
                break;
        }

    }
    return nil;
}

-(NSMutableArray *)crossPatternCheck
{
    NSMutableArray *patternArray;
    
    for (SnakeNode *node in _snakeBody) {
        
        int r = [node nodeIndexRow];
        int c = [node nodeIndexCol];
        AssetType type = node.assetType;
        
        SnakeNode *node2;
        SnakeNode *node3;
        SnakeNode *node4;
        SnakeNode *node5;

        node2 = [self hasPatternRow:r-1 col:c assetType:type];
        node3 = [self hasPatternRow:r col:c-1 assetType:type];
        node4 = [self hasPatternRow:r+1 col:c assetType:type];
        node5 = [self hasPatternRow:r col:c+1 assetType:type];
        
        if ( node2 && node3 && node4 && node5) {
            
            patternArray = [[NSMutableArray alloc]initWithArray: @[node,node2,node3,node4,node5]];
            return patternArray;
        }

    }
    return nil;
}

-(NSMutableArray *)hallowSquarePatternCheck
{
    NSMutableArray *patternArray;
    
    for (SnakeNode *node in _snakeBody) {
        
        int r = [node nodeIndexRow];
        int c = [node nodeIndexCol];
        AssetType type = node.assetType;
        
        SnakeNode *node2;
        SnakeNode *node3;
        SnakeNode *node4;
        
        node2 = [self hasPatternRow:r+1 col:c-1 assetType:type];
        node3 = [self hasPatternRow:r+1 col:c+1 assetType:type];
        node4 = [self hasPatternRow:r+2 col:c assetType:type];
        
        if ( node2 && node3 && node4) {
            
            patternArray = [[NSMutableArray alloc]initWithArray: @[node,node2,node3,node4]];
            return patternArray;
        }
        
    }
    return nil;
}

-(NSMutableArray *)xPatternCheck
{
    NSMutableArray *patternArray;
    
    for (SnakeNode *node in _snakeBody) {
        
        int r = [node nodeIndexRow];
        int c = [node nodeIndexCol];
        AssetType type = node.assetType;
        
        SnakeNode *node2;
        SnakeNode *node3;
        SnakeNode *node4;
        SnakeNode *node5;
        
        node2 = [self hasPatternRow:r-1 col:c-1 assetType:type];
        node3 = [self hasPatternRow:r-1 col:c+1 assetType:type];
        node4 = [self hasPatternRow:r+1 col:c-1 assetType:type];
        node5 = [self hasPatternRow:r+1 col:c+1 assetType:type];
        
        if ( node2 && node3 && node4 && node5) {
            
            patternArray = [[NSMutableArray alloc]initWithArray: @[node,node2,node3,node4,node5]];
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
            SnakeNode *n = [self hasPatternRow:r col:c assetType:type];
            if (!n)
                checkCol = NO;
            else {
                [patternArray addObject:n];
                count++;
            }
        }
    
        if (count >= chain) {
            
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
            SnakeNode *n = [self hasPatternRow:r col:c assetType:type];
            if (!n)
                checkCol = NO;
            else {
                [patternArray addObject:n];
                count++;
            }
        }
        
        if (count >= chain) {
            
            return patternArray;
        }
    }
    return nil;
}

- (SnakeNode *)hasPatternRow:(int)row col:(int)col assetType:(AssetType)type
{
    for (SnakeNode *node in _snakeBody) {
        
        if ([node nodeIndexRow] == row && [node nodeIndexCol] == col && node.assetType == type) {
            
            return node;
        }
    }
    return nil;
}

-(NSMutableArray *)diagonalDownPatternCheck
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
            c = c+1;
            SnakeNode *n = [self hasPatternRow:r col:c assetType:type];
            if (!n)
                checkCol = NO;
            else {
                [patternArray addObject:n];
                count++;
            }
        }
        
        if (count >= chain) {
            
            return patternArray;
        }
    }
    return nil;

}

-(NSMutableArray *)diagonalUpPatternCheck
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
            c = c-1;
            SnakeNode *n = [self hasPatternRow:r col:c assetType:type];
            if (!n)
                checkCol = NO;
            else {
                [patternArray addObject:n];
                count++;
            }
        }
        
        if (count >= chain) {
            
            return patternArray;
        }
    }
    return nil;
}

#pragma mark - Combo

-(void)explodeBody:(SnakeNode *)removeBody
{
    CGRect bodyFrame = [removeBody convertRect:removeBody.bounds toView:_gamePad];
    bodyFrame.origin.y = _gamePad.frame.size.height - bodyFrame.origin.y;
    CGFloat posX = bodyFrame.origin.x+bodyFrame.size.width/2;
    CGFloat posY = bodyFrame.origin.y-bodyFrame.size.height/2;
    
    [_particleView newExplosionWithPosX:posX andPosY:posY assetType:removeBody.assetType];
    
    removeBody.hidden = YES;
}

#pragma mark - Body Animations

- (void)startBlinkAnimation:(SnakeNode *)node
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

-(CABasicAnimation *)shakeAnimation:(NSInteger)i
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

-(CABasicAnimation *)rotateAnimation
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
    [[self snakeHead].layer addAnimation:[self rotateAnimation] forKey:nil];
}

@end
