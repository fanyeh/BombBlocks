//
//  Snake.m
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/5/1.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import "Snake.h"
#import "SnakeSkill.h"
#import "GameAsset.h"

@implementation Snake
{
    NSMutableDictionary *turningNodeTags;
    UILabel *exclamation;
    UIView *exclamationView;
    CGFloat exalamtionWidth;
    NSString *exclamationText;
    NSInteger chain;     // Same color required to form a combo
    CGRect headFrame;
    NSMutableArray *walls;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithSnakeHeadDirection:(MoveDirection)direction gamePad:(UIView *)gamePad headFrame:(CGRect)frame
{
    headFrame = frame; //CGRectMake(147, 189, 20, 20);
    self = [self initWithFrame:headFrame];
    if (self) {
        
        self.backgroundColor = [UIColor colorWithWhite:0.200 alpha:1.000];
        self.layer.cornerRadius = headFrame.size.width/4;
        
        _leftEye = [[UIView alloc]initWithFrame:CGRectMake(2, 2, 5, 5)];
        _leftEye.layer.cornerRadius = _leftEye.frame.size.width/2;
        _leftEye.layer.borderWidth = 1.5;
        _leftEye.layer.borderColor = [[UIColor whiteColor]CGColor];
        [self addSubview:_leftEye];
        
        _rightEye = [[UIView alloc]initWithFrame:CGRectMake(2, 13, 5, 5)];
        _rightEye.layer.borderWidth = 1.5;
        _rightEye.layer.borderColor = [[UIColor whiteColor]CGColor];
        _rightEye.layer.cornerRadius = _rightEye.frame.size.width/2;
        [self addSubview:_rightEye];

        _snakeMouth = [[UIView alloc]initWithFrame:CGRectMake(15, 4, 12, 12)];
        _snakeMouth.layer.cornerRadius = _snakeMouth.frame.size.width/2;
        _snakeMouth.layer.borderColor = [[UIColor whiteColor]CGColor];
        [self addSubview:_snakeMouth];
        
        _gamePad = gamePad;
        _snakeBody = [[NSMutableArray alloc]init];
        _turningNodes = [[NSMutableDictionary alloc]init];
        _bodyDirections = [[NSMutableDictionary alloc]init];
        turningNodeTags = [[NSMutableDictionary alloc]init];
        _snakeLength = 1;
        self.tag = 0;
        _xOffset = headFrame.size.width+1;
        _yOffset = headFrame.size.height+1;
        [_snakeBody addObject:self];
        [_bodyDirections setObject:[NSNumber numberWithInt:direction] forKey:[NSNumber numberWithInteger:0]];
        
        exalamtionWidth = 85;
        exclamationView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, exalamtionWidth, 15)];
        exclamationText = @"Combo!";
        
        [self resetExclamationDirection:direction];
        [_gamePad addSubview:exclamationView];
        
        switch (direction ) {
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
        
        chain = 2;
        _skill = [[SnakeSkill alloc]init];
        _snakeType = [[SnakeType alloc]initWithSnakeType:kSnakeTypeStrength];
    }
    return self;
}

#pragma mark - Reset Snake

- (void)resetSnake
{
    for (UIView *v in _snakeBody) {
        if (v.tag > 0)
            [v removeFromSuperview];
    }
    
    MoveDirection direction = [self headDirection];
    UIView *snakeHead = [self snakeHead];
    snakeHead.frame = headFrame;

    [_snakeBody removeAllObjects];
    [_turningNodes removeAllObjects];
    [_bodyDirections removeAllObjects];
    [turningNodeTags removeAllObjects];
    _snakeLength = 1;
    
    _xOffset = headFrame.size.width+1;
    _yOffset = headFrame.size.height+1;
    [_snakeBody addObject:snakeHead];
    
    [_bodyDirections setObject:[NSNumber numberWithInt:direction] forKey:[NSNumber numberWithInteger:0]];
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

    [self resetExclamationDirection:direction];

}

- (void)resetExclamationDirection:(MoveDirection)direction
{
    if ([exclamation superview])
        [exclamation removeFromSuperview];
    exclamationView.hidden = YES;
    exclamation = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, exalamtionWidth, 15)];
    exclamation.text = exclamationText;
    exclamation.textColor = [UIColor blackColor];
    exclamation.textAlignment = NSTextAlignmentRight;

    exclamation.font = [UIFont fontWithName:@"ChalkboardSE-Bold" size:15];
    
    [exclamationView addSubview:exclamation];
    
    switch (direction) {
            
        case kMoveDirectionUp:
            
            exclamationView.frame = CGRectOffset([self snakeHead].frame, -exalamtionWidth/2+10, -25);
            exclamation.textAlignment = NSTextAlignmentCenter;
            break;
            
        case kMoveDirectionDown:
            
            exclamationView.frame = CGRectOffset([self snakeHead].frame, -exalamtionWidth/2+10, 25);
            exclamation.textAlignment = NSTextAlignmentCenter;
            break;
            
        case kMoveDirectionLeft:
            
            exclamationView.frame = CGRectOffset([self snakeHead].frame, 0, -20);
            exclamation.textAlignment = NSTextAlignmentLeft;
            break;
            
        case kMoveDirectionRight:
            
            exclamationView.frame = CGRectOffset([self snakeHead].frame, -exalamtionWidth+20 , -20);
            exclamation.textAlignment = NSTextAlignmentRight;
            break;
    }
}

-(void)updateExclamationText
{
    exclamationText = [NSString stringWithFormat:@"Combo %ld!",_combos];
    exclamation.text = exclamationText;
}

#pragma mark - Directions

- (MoveDirection)getBodyDirection:(UIView *)body
{
   return [[_bodyDirections objectForKey:[NSNumber numberWithInteger:body.tag]] intValue];
}

- (MoveDirection)headDirection
{
   return [[_bodyDirections objectForKey:[NSNumber numberWithInteger:0]] intValue];
}

- (BOOL)changeDirectionWithGameIsOver:(BOOL)gameIsOver
{
    MoveDirection direction;
    
    UIView *tail = [self snakeTail];
    
    for (UIView *view in _snakeBody) {
        
        CGRect newFrame = CGRectMake((int)roundf(view.frame.origin.x), (int)roundf(view.frame.origin.y), (int)roundf(view.frame.size.width), (int)roundf(view.frame.size.height));
        
        NSValue *directionValue = [_turningNodes objectForKey:[NSValue valueWithCGRect:newFrame]];
        
        // If body frame = turning node frame , then there's a direction change
        if (directionValue) {
            direction = [[_turningNodes objectForKey:[NSValue valueWithCGRect:newFrame]] intValue];
            
            // Set new direction for body
            [_bodyDirections setObject:[NSNumber numberWithInt:direction] forKey:[NSNumber numberWithInteger:view.tag]];
            
            // Remove turning node if last body has passed the node
            if (view.tag == tail.tag) {
                [_turningNodes removeObjectForKey:[NSValue valueWithCGRect:newFrame]];
            }
            
        } else
            direction = [[_bodyDirections objectForKey:[NSNumber numberWithInteger:view.tag]] intValue];
        
        CGRect newPosition = [self getNewPosition:view direction:direction];
        
        // Check if snake head touched body or gampad bounds
        
        if (view.tag == 0 && !_isRotate) {
            
            for (UIView *v in _snakeBody) {
                // If head touched body , game is over
                if (CGRectIntersectsRect(newPosition, v.frame) && v.tag != 0) {
                    gameIsOver  = YES;
                    break;
                }
            }
            
            if ([self touchedScreenBounds:newPosition]) {
                gameIsOver  = YES;
            }
            
            if ([self touchWall:newPosition])
                gameIsOver = YES;
        }
        
        // If not game over then update the frame of each snake part view
        
        if (!gameIsOver) {
            CGRect newFrame = newPosition;
            view.frame = CGRectMake((int)roundf(newFrame.origin.x), (int)roundf(newFrame.origin.y), (int)roundf(newFrame.size.width), (int)roundf(newFrame.size.height));
            
            if (view.tag == 0) {
                // Update exclamation mark position
                
                exclamationView.frame = [self getNewPosition:exclamationView direction:[self headDirection]];
            }
        }
        else {
            return YES;
        }
    }
    return NO;
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

-(void)setTurningNode:(CGPoint)location
{
    CGPoint headOrigin = [self snakeHead].frame.origin;
    MoveDirection direction;
    switch ([self headDirection]) {
        case kMoveDirectionUp:
            if (location.x > headOrigin.x)
                direction = kMoveDirectionRight;
            else if (location.x < headOrigin.x)
                direction = kMoveDirectionLeft;
            break;
        case kMoveDirectionDown:
            if (location.x > headOrigin.x)
                direction = kMoveDirectionRight;
            else if (location.x < headOrigin.x)
                direction = kMoveDirectionLeft;
            break;
        case kMoveDirectionLeft:
            if (location.y > headOrigin.y)
                direction = kMoveDirectionDown;
            else if (location.y < headOrigin.y)
                direction = kMoveDirectionUp;
            break;
        case kMoveDirectionRight:
            if (location.y > headOrigin.y)
                direction = kMoveDirectionDown;
            else if (location.y < headOrigin.y)
                direction = kMoveDirectionUp;
            break;
    }
    
    switch ([self headDirection] ) {
        case kMoveDirectionRight:
            if (direction == kMoveDirectionDown) {
                [self resetExclamationDirection:kMoveDirectionDown];
                [self snakeHead].transform = CGAffineTransformMakeRotation(M_PI/2); // ok
            }
            else if (direction == kMoveDirectionUp) {
                [self resetExclamationDirection:kMoveDirectionUp];
                [self snakeHead].transform = CGAffineTransformMakeRotation(-M_PI/2); // ok
            }
            break;
        case kMoveDirectionLeft:
            if (direction == kMoveDirectionDown) {
                [self resetExclamationDirection:kMoveDirectionDown];
                [self snakeHead].transform =  CGAffineTransformMakeRotation(M_PI/2); // ok
            }
            else if (direction == kMoveDirectionUp){
                [self resetExclamationDirection:kMoveDirectionUp];
                [self snakeHead].transform = CGAffineTransformMakeRotation(-M_PI/2); // ok
            }
            break;
        case kMoveDirectionUp:
            if (direction == kMoveDirectionLeft){
                [self resetExclamationDirection:kMoveDirectionLeft];
                [self snakeHead].transform =  CGAffineTransformMakeRotation(-M_PI); // ok
            }
            else if (direction == kMoveDirectionRight){
                [self resetExclamationDirection:kMoveDirectionRight];
                [self snakeHead].transform = CGAffineTransformMakeRotation(M_PI_2 - M_PI/2); // ok
            }
            break;
        case kMoveDirectionDown:
            if (direction == kMoveDirectionLeft){
                [self resetExclamationDirection:kMoveDirectionLeft];
                [self snakeHead].transform = CGAffineTransformMakeRotation(-M_PI); // ok
            }

            else if (direction == kMoveDirectionRight){
                [self resetExclamationDirection:kMoveDirectionRight];
                [self snakeHead].transform = CGAffineTransformMakeRotation(M_PI_2 - M_PI/2); // ok
            }
            break;
    }
    
    CGRect newFrame = [self snakeHead].frame;
    newFrame = CGRectMake((int)roundf(newFrame.origin.x), (int)roundf(newFrame.origin.y), (int)roundf(newFrame.size.width), (int)roundf(newFrame.size.height));
    [self snakeHead].frame = newFrame;
    [_turningNodes setObject:[NSNumber numberWithInt:direction] forKey:[NSValue valueWithCGRect:newFrame]];
}

- (void)updateTurningNode
{
    UIView *tail = [self snakeTail];
    
    NSValue *directionValue = [_turningNodes objectForKey:[NSValue valueWithCGRect:tail.frame]];
    
    // If body frame = turning node frame , then there's a direction change
    if (directionValue)
        [_turningNodes removeObjectForKey:[NSValue valueWithCGRect:tail.frame]];
}

#pragma mark - Out of bound

- (BOOL)touchedScreenBounds:(CGRect)newPostion
{
    CGRect screen= _gamePad.bounds;
    CGRect topBound = CGRectMake(0, -2, screen.size.width, 1);
    CGRect botBound = CGRectMake(0, screen.size.height+1, screen.size.width, 1);
    CGRect leftBound = CGRectMake(-2, 0, 1, screen.size.height);
    CGRect rightBound = CGRectMake(screen.size.width+1, 0, 1, screen.size.height);
 
    if (CGRectIntersectsRect(newPostion, topBound)) {
        return YES;
    } else if (CGRectIntersectsRect(newPostion, botBound)) {
        return YES;

    } else if (CGRectIntersectsRect(newPostion, leftBound)) {
        return YES;

    } else if (CGRectIntersectsRect(newPostion, rightBound)) {
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
    for (GameAsset *asset in walls) {
        if (asset.gameAssetType == kAssetTypeWall)
            if (CGRectIntersectsRect(newPosition, asset.frame))
                return YES;
    }
    return NO;
}

#pragma mark - Snake Body

- (SnakeBody *)addSnakeBodyWithAsset:(GameAsset *)assetView
{
    CGRect bodyFrame;
    CGRect snakeTailFrame =  [self snakeTail].frame;
    MoveDirection direction = [self getBodyDirection:[self snakeTail]];
    
    switch (direction) {
        case kMoveDirectionUp:
            bodyFrame = CGRectOffset(snakeTailFrame, 0, _yOffset);
            break;
        case kMoveDirectionDown:
            bodyFrame = CGRectOffset(snakeTailFrame, 0, -_yOffset);
            break;
        case kMoveDirectionLeft:
            bodyFrame = CGRectOffset(snakeTailFrame, _xOffset, 0);
            break;
        case kMoveDirectionRight:
            bodyFrame = CGRectOffset(snakeTailFrame, -_xOffset, 0);
            break;
    }
    
    SnakeBody *snakeBody = [[SnakeBody alloc]initWithFrame:bodyFrame];
    snakeBody.layer.cornerRadius = bodyFrame.size.width/4;
    snakeBody.backgroundColor = assetView.backgroundColor;
    snakeBody.tag = _snakeLength;
//    snakeBody.skillType.type = dot.skillType.type;
    [_snakeBody addObject:snakeBody];
    [_bodyDirections setObject:[NSNumber numberWithInt:direction] forKey:[NSNumber numberWithInteger:snakeBody.tag]];
    _snakeLength ++;
    
    return snakeBody;
}

- (UIView *)snakeHead
{
    return [_snakeBody firstObject];
}

- (UIView *)snakeTail
{
    return [_snakeBody lastObject];
}

- (void)removeSnakeBody:(UIView *)body
{
    [_bodyDirections removeObjectForKey:[NSNumber numberWithInteger:body.tag]];
    [_snakeBody removeObject:body];
}

- (void)removeSnakeBodyFromArray:(NSMutableArray *)removeArray
{
    for (UIView *body in removeArray) {
        [_bodyDirections removeObjectForKey:[NSNumber numberWithInteger:body.tag]];
    }
    
    [_snakeBody removeObjectsInArray:removeArray];
}

- (void)startRotate
{
    _isRotate = YES;
    [[self snakeHead].layer addAnimation:[self wobbleAnimation] forKey:nil];
    [self showExclamation:YES];
}

- (void)stopRotate
{
    _isRotate = NO;
    [[self snakeHead].layer removeAllAnimations];
    [self showExclamation:NO];

}

#pragma mark - Combo

- (BOOL)checkCombo:(void(^)(void))completeBlock
{
    UIColor *repeatColor;
    NSInteger startIndex = 0;
    NSInteger endIndex = 0;
    for (UIView *v in _snakeBody) {
        if (![repeatColor isEqual:v.backgroundColor]) {
            repeatColor = v.backgroundColor;
            startIndex = [_snakeBody indexOfObject:v];
            endIndex = startIndex;
        } else {
            endIndex = [_snakeBody indexOfObject:v];
        }
        
        if (endIndex - startIndex == chain) {
            
            [self updateInitSkillView:[_snakeBody objectAtIndex:startIndex]];
            
            // Shake snake head
            if (!_isRotate)
                [self startRotate];
            
            [self comboAnimationStartIndex:startIndex endIndex:endIndex completeBlock:completeBlock mouthColor:v.backgroundColor otherCombo:NO];
            
            
            return YES;
        }
    }
    completeBlock();
    return NO;
}

// Single body color check
- (void)cancelSnakeBodyByColor:(UIColor *)color complete:(void(^)(void))completeBlock
{
    BOOL completeCheck = YES;
    // Remove each body with same color
    for (SnakeBody *v in _snakeBody) {
        if ([v.backgroundColor isEqual:color]) {
            NSInteger index = [_snakeBody indexOfObject:v];
            [self removeSnakeBodyByIndex:index andColor:v.backgroundColor complete:completeBlock];
            completeCheck = NO;
            
            // Update skill adder
            [_skill updateSkillAdder:v.skillType.type adder:1];
            
            break;
        }
    }
    
    // Check if there is other combos
    if (completeCheck)
        [self otherCombo:completeBlock];
}

// Single body removal
-(void)removeSnakeBodyByIndex:(NSInteger)index andColor:(UIColor *)color complete:(void(^)(void))completeBlock
{
    for (NSInteger i=index; i < [_snakeBody count];i++) {
        if (i < [_snakeBody count] -1) {
            // Next body
            SnakeBody *currentBody = [_snakeBody objectAtIndex:i];
            SnakeBody *nextBody = [_snakeBody objectAtIndex:i+1];
            
            [UIView animateWithDuration:0.0 animations:^{
                
                currentBody.backgroundColor = nextBody.backgroundColor;
                
            }];
        }
    }
    
    [UIView animateWithDuration:0.1 animations:^{
        
        self.snakeTail.alpha = 0;
        
    } completion:^(BOOL finished) {
        
        [self.snakeTail removeFromSuperview];
        [self updateTurningNode];
        [self.snakeBody removeLastObject];
        [self cancelSnakeBodyByColor:color complete:completeBlock];
    }];
}

-(BOOL)otherCombo:(void(^)(void))completeBlock
{
    UIColor *mouthColor;
    UIColor *repeatColor;
    NSInteger startIndex = 0;
    NSInteger endIndex = 0;
    BOOL hasCombo = NO;
    
    for (SnakeBody *v in _snakeBody) {
        
        if (![repeatColor isEqual:v.backgroundColor]) {
            
            if (hasCombo) {
                // Invalidate timer if there combo
                
                [self updateSupplementSkill:[_snakeBody objectAtIndex:startIndex]];

                
                [self comboAnimationStartIndex:startIndex endIndex:endIndex completeBlock:completeBlock mouthColor:mouthColor otherCombo:YES];
                
                
                return YES;
            } else {
                repeatColor = v.backgroundColor;
                startIndex = [_snakeBody indexOfObject:v];
                endIndex = startIndex;
            }
        } else {
            endIndex = [_snakeBody indexOfObject:v];
            
            // More than chain
            if (endIndex - startIndex == chain) {
                mouthColor = repeatColor;
                hasCombo = YES;
            }
            
            if ([v isEqual:[_snakeBody lastObject]] && hasCombo) {
                
                [self updateSupplementSkill:[_snakeBody objectAtIndex:startIndex]];

                
                [self comboAnimationStartIndex:startIndex endIndex:endIndex completeBlock:completeBlock mouthColor:mouthColor otherCombo:YES];
                

                return YES;
                
            }
        }
    }
    // If no other combo call the complete block
    completeBlock();
    return NO;
}

-(void)removeSnakeBodyByRangeStart:(NSInteger)start andRange:(NSInteger)range complete:(void(^)(void))completeBlock
{
    if (range == 0) {
        
        [self otherCombo:completeBlock];
        
    } else {

        for (NSInteger i=start; i < [_snakeBody count] -1 ;i++) {
            
            if (i < [_snakeBody count] -1) {
                
                // Next body
                SnakeBody *currentBody = [_snakeBody objectAtIndex:i];
                SnakeBody *nextBody = [_snakeBody objectAtIndex:i+1];
                currentBody.backgroundColor = nextBody.backgroundColor;
            }
        }
        
        [UIView animateWithDuration:0.1 animations:^{
            
            self.snakeTail.alpha = 0;
            
        } completion:^(BOOL finished) {
            
            [self.snakeTail removeFromSuperview];
            [self updateTurningNode];
            [self.snakeBody removeLastObject];
            [self removeSnakeBodyByRangeStart:start andRange:range-1 complete:completeBlock];
        }];
        
    }
}

- (void)comboAnimationStartIndex:(NSInteger)start endIndex:(NSInteger)end
                   completeBlock:(void(^)(void))completeBlock
                      mouthColor:(UIColor *)color
                      otherCombo:(BOOL)other
{
    
    _leftEye.alpha = 0;
    _rightEye.alpha = 0;
    _snakeMouth.backgroundColor = color;
    _combos++;
    [self updateExclamationText];
    
    for (NSInteger i = start ; i < end +1 ; i ++) {
        
        SnakeBody *u = _snakeBody[i];
        [u.layer addAnimation:[self bodyAnimation:i] forKey:nil];
        [_skill updateSkillAdder:u.skillType.type adder:1];
    }
    
    [UIView animateWithDuration:1 animations:^{
        
        _leftEye.alpha = 1;
        _rightEye.alpha = 1;
        _leftEye.layer.borderWidth = 0.5;
        _rightEye.layer.borderWidth = 0.5;
        
    } completion:^(BOOL finished) {
        
        for (NSInteger i = start ; i < end +1 ; i ++) {
            SnakeBody *u = _snakeBody[i];
            [u.layer removeAllAnimations];
        }
        
        _leftEye.layer.borderWidth = 1.5;
        _rightEye.layer.borderWidth = 1.5;
        
        if (other)
            [self removeSnakeBodyByRangeStart:start andRange:(end - start) + 1 complete:completeBlock];
        else
            [self cancelSnakeBodyByColor:color complete:completeBlock];
    }];
    
}

#pragma mark - Skill View

- (void)updateInitSkillView:(SnakeBody *)body
{
    _initSkillView.backgroundColor = body.backgroundColor;
    [_skill setInitialSkill:body.skillType.type];
}

- (void)updateSupplementSkill:(SnakeBody *)body
{
    if ([_supplementSkillView1.backgroundColor isEqual:[UIColor whiteColor]]) {
        _supplementSkillView1.backgroundColor = body.backgroundColor;
        [_skill setSupplementSkill:body.skillType.type];

    } else if ([_supplementSkillView2.backgroundColor isEqual:[UIColor whiteColor]] && ![_supplementSkillView1.backgroundColor isEqual:body.backgroundColor]) {
        _supplementSkillView2.backgroundColor = body.backgroundColor;
        [_skill setSupplementSkill:body.skillType.type];
    }
}

#pragma mark - Body Animations

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

- (void)mouthAnimation:(float)timeInterval
{
    float duration = timeInterval;
    float closeInsetSize =  _snakeMouth.frame.size.width/3;
    
    [UIView animateWithDuration:duration animations:^{
        
        // Mouth Close
        _snakeMouth.frame = CGRectInset(_snakeMouth.frame, closeInsetSize, closeInsetSize);
        
    } completion:^(BOOL finished) {
        
        _snakeMouth.hidden = YES;
        
        // Mouth Open
        _snakeMouth.frame = CGRectInset(_snakeMouth.frame, -closeInsetSize, -closeInsetSize);
        
    }];
}

#pragma mark - Exclamation Animation

-(CABasicAnimation *)exclamationAnimation
{
    CGFloat startAngle = - M_PI/60;
    CGFloat endAngle = M_PI/60;
 
    CABasicAnimation* anim = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    [anim setToValue:[NSNumber numberWithFloat:endAngle]]; // satrt angle
    [anim setFromValue:[NSNumber numberWithDouble:startAngle]]; // rotation angle
    [anim setDuration:0.1]; // rotate speed
    [anim setRepeatCount:HUGE_VAL];
    [anim setAutoreverses:YES];
    return anim;
}

- (void)showExclamation:(BOOL)show
{
    if (show) {
        exclamationView.hidden = NO;
        [exclamation.layer addAnimation:[self exclamationAnimation] forKey:nil];
        [_gamePad bringSubviewToFront:exclamationView];
    }
    else {
        exclamationView.hidden = YES;
        [exclamation.layer removeAllAnimations];
    }
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
