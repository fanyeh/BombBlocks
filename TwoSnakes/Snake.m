//
//  Snake.m
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/5/1.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import "Snake.h"

@implementation Snake
{
    NSMutableDictionary *turningNodeTags;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithSnakeHead:(UIView *)headView andDirection:(MoveDirection)direction
{
    self = [self initWithFrame:headView.frame];
    if (self) {
        _snakeBody = [[NSMutableArray alloc]init];
        _turningNodes = [[NSMutableDictionary alloc]init];
        _bodyDirections = [[NSMutableDictionary alloc]init];
        turningNodeTags = [[NSMutableDictionary alloc]init];
        _snakeLength = 1;
        headView.tag = 0;
        _xOffset = headView.frame.size.width+1;
        _yOffset = headView.frame.size.height+1;
        [_snakeBody addObject:headView];
        [_bodyDirections setObject:[NSNumber numberWithInt:direction] forKey:[NSNumber numberWithInteger:0]];
        
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
        

    }
    return self;
}

#pragma mark - Reset Snake

- (void)resetSnake:(UIView *)headView andDirection:(MoveDirection)direction
{
    [_snakeBody removeAllObjects];
    [_turningNodes removeAllObjects];
    [_bodyDirections removeAllObjects];
    [turningNodeTags removeAllObjects];
    _snakeLength = 1;
    headView.tag = 0;
    _xOffset = headView.frame.size.width+1;
    _yOffset = headView.frame.size.height+1;
    [_snakeBody addObject:headView];
    [_bodyDirections setObject:[NSNumber numberWithInt:direction] forKey:[NSNumber numberWithInteger:0]];
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
        
        CGRect newPosition;
        
        switch (direction) {
            case kMoveDirectionUp:
                newPosition = CGRectOffset(view.frame, 0, -_yOffset);
                break;
            case kMoveDirectionDown:
                newPosition = CGRectOffset(view.frame, 0, _yOffset);
                break;
            case kMoveDirectionLeft:
                newPosition = CGRectOffset(view.frame, -_xOffset, 0);
                break;
            case kMoveDirectionRight:
                newPosition = CGRectOffset(view.frame, _xOffset, 0);
                break;
        }
        
        if (view.tag == 0) {
            
            for (UIView *v in _snakeBody) {
                // If head touched body , game is over
                if (CGRectIntersectsRect(newPosition, v.frame) && v.tag != 0) {
                    NSLog(@"Game over");
                    gameIsOver  = YES;
                    break;
                }
            }
            
            if ([self touchedScreenBounds:newPosition]) {
                NSLog(@"Game over : out bound");
                gameIsOver  = YES;
            }
        }
        
        if (!gameIsOver) {
            CGRect newFrame = newPosition;
            view.frame = CGRectMake((int)roundf(newFrame.origin.x), (int)roundf(newFrame.origin.y), (int)roundf(newFrame.size.width), (int)roundf(newFrame.size.height));
        }
        else
            return YES;
    }
    return NO;
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
            if (direction == kMoveDirectionDown)
                [self snakeHead].transform = CGAffineTransformMakeRotation(M_PI/2); // ok
            else if (direction == kMoveDirectionUp)
                [self snakeHead].transform = CGAffineTransformMakeRotation(-M_PI/2); // ok
            break;
        case kMoveDirectionLeft:
            if (direction == kMoveDirectionDown)
                [self snakeHead].transform =  CGAffineTransformMakeRotation(M_PI/2); // ok
            else if (direction == kMoveDirectionUp)
                [self snakeHead].transform = CGAffineTransformMakeRotation(-M_PI/2); // ok
            break;
        case kMoveDirectionUp:
            if (direction == kMoveDirectionLeft)
                [self snakeHead].transform =  CGAffineTransformMakeRotation(-M_PI); // ok
            else if (direction == kMoveDirectionRight)
                [self snakeHead].transform = CGAffineTransformMakeRotation(M_PI_2 - M_PI/2); // ok
            break;
        case kMoveDirectionDown:
            if (direction == kMoveDirectionLeft)
                [self snakeHead].transform = CGAffineTransformMakeRotation(-M_PI); // ok
            
            else if (direction == kMoveDirectionRight)
                [self snakeHead].transform = CGAffineTransformMakeRotation(M_PI_2 - M_PI/2); // ok
            
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

#pragma mark - Dots

- (BOOL)isEatingDot:(UIView *)dot
{
    if ([[NSValue valueWithCGRect:[self snakeHead].frame] isEqualToValue:[NSValue valueWithCGRect:dot.frame]])
        return YES;
    else
        return NO;
}

- (BOOL)isOverlayWithDotFrame:(CGRect)dotFrame
{
    for (UIView *view in _snakeBody) {
        if ([[NSValue valueWithCGRect:view.frame] isEqualToValue:[NSValue valueWithCGRect:dotFrame]]) {
            return YES;
        }
    }
    return NO;
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


#pragma mark - Snake Body

- (UIView *)addSnakeBodyWithColor:(UIColor *)color
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
    
    UIView *snakeBody = [[UIView alloc]initWithFrame:bodyFrame];
    
    snakeBody.backgroundColor = color;
    snakeBody.tag = _snakeLength;
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

@end
