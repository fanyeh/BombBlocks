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
        
        self.layer.borderColor = PadBackgroundColor.CGColor;
        self.layer.borderWidth = 4;
        self.backgroundColor = [UIColor whiteColor];
        [self setNodeIndexRow:3 andCol:2];
        self.name = @"head";
        
        // Snake head image
        UIImageView *headImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, headFrame.size.width, headFrame.size.height)];
        headImageView.image = [UIImage imageNamed:@"head.png"];
        headImageView.layer.cornerRadius = headFrame.size.width/4;
        headImageView.transform = CGAffineTransformMakeRotation(-M_PI/2);
        //[self addSubview:headImageView];
        
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
    
    [self setNodeIndexRow:3 andCol:2];
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
        
        __block CGRect previousFrame = newPosition;
        __block CGRect currentFrame;
        
        __block MoveDirection previousDirection = direction;
        __block MoveDirection currentDirection;
        
        __block NodeIndex previousNodePath;
        __block NodeIndex currentNodePath;
        
        [UIView animateWithDuration:0.2 animations:^{
            
            for (NSInteger i=0; i < [_snakeBody count];i++) {
                
                SnakeNode *currentBody = [_snakeBody objectAtIndex:i];
                currentFrame = currentBody.frame;
                currentDirection = currentBody.direction;
                currentNodePath = currentBody.nodePath;
                
                if (i==0)
                    [self updateSnakeNodeIndex:currentBody toFrame:previousFrame];
                else
                    currentBody.nodePath = previousNodePath;
                
                currentBody.frame = previousFrame;
                currentBody.direction = previousDirection;
                
                previousFrame = currentFrame;
                previousDirection = currentDirection;
                previousNodePath = currentNodePath;
                
            }
            
        } completion:^(BOOL finished) {
            
            [self addSnakeBody];
            
        }];
        
    } else {
        
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
    
//    if (bodyFrame.size.width < 40) {
//        
//        NSLog(@"Direction = %d , Body %@ : Tail %@",direction,NSStringFromCGRect(bodyFrame), NSStringFromCGRect(snakeTailFrame));
//
//    }
    GameAsset *asset = [[GameAsset alloc]init];
    int randomAsset = arc4random()%4;
    
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
    snakeBody.layer.borderColor = [UIColor colorWithWhite:0.400 alpha:1.000].CGColor;
    snakeBody.layer.borderWidth = 4 ;
    [snakeBody setNodeIndexRow:row andCol:col];
    snakeBody.direction = direction;
    CGFloat imageSize = 16;
    UIImageView *bodyImageView = [[UIImageView alloc]initWithFrame:CGRectMake(imageSize/2,
                                                                              imageSize/2,
                                                                              bodyFrame.size.width-imageSize,
                                                                              bodyFrame.size.height-imageSize)];
    switch (asset.gameAssetType) {
        case kAssetTypeGreen:
            bodyImageView.image = [UIImage imageNamed:@"green.png"];
            snakeBody.nodeColor = GreenDotColor;
            break;
        case kAssetTypeBlue:
            bodyImageView.image = [UIImage imageNamed:@"blue.png"];
            snakeBody.nodeColor = BlueDotColor;
            break;
        case kAssetTypeRed:
            bodyImageView.image = [UIImage imageNamed:@"red.png"];
            snakeBody.nodeColor = RedDotColor;
            break;
        case kAssetTypeYellow:
            bodyImageView.image = [UIImage imageNamed:@"yellow.png"];
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
    [UIView animateWithDuration:0.2 animations:^{
        
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
            
            n.layer.borderColor = n.nodeColor.CGColor;
            n.alpha = 0.5;
        }
        
        [UIView animateWithDuration: 1.0 animations:^{
            
            for (SnakeNode *n in allPatterns) {
                n.alpha = 1.0;
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
    [UIView animateWithDuration:0.5 animations:^{
        
        for (NSInteger i=index; i < [_snakeBody count];i++) {
            
            SnakeNode *currentBody = [_snakeBody objectAtIndex:i];
            currentFrame = currentBody.frame;
            currentDirection = currentBody.direction;
            currentNodePath = currentBody.nodePath;
            
            // Set node indexpath based on move to frame position
            //[self updateSnakeNodeIndex:currentBody toFrame:previousFrame];
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
            [self removeSnakeBodyFromArray:removalArray];
        else // Check if there are more combos
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
                node2 = [self hasPatternRow:r col:c+1 assetType:type];
                node3 = [self hasPatternRow:r+1 col:c assetType:type];
                node4 = [self hasPatternRow:r+1 col:c+1 assetType:type];
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
            SnakeNode *n = [self hasPatternRow:r col:c assetType:type];
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
            SnakeNode *n = [self hasPatternRow:r col:c assetType:type];
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

- (SnakeNode *)hasPatternRow:(int)row col:(int)col assetType:(AssetType)type
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
    
    [_particleView newExplosionWithPosX:posX andPosY:posY assetType:removeBody.assetType];
    
    removeBody.hidden = YES;
}

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
