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
        _xOffset = headView.frame.size.width;
        _yOffset = headView.frame.size.height;
        [_snakeBody addObject:headView];
        [_bodyDirections setObject:[NSNumber numberWithInt:direction] forKey:[NSNumber numberWithInteger:0]];
    }
    return self;
}

- (void)resetSnake:(UIView *)headView andDirection:(MoveDirection)direction
{
    [_snakeBody removeAllObjects];
    [_turningNodes removeAllObjects];
    [_bodyDirections removeAllObjects];
    [turningNodeTags removeAllObjects];
    _snakeLength = 1;
    headView.tag = 0;
    _xOffset = headView.frame.size.width;
    _yOffset = headView.frame.size.height;
    [_snakeBody addObject:headView];
    [_bodyDirections setObject:[NSNumber numberWithInt:direction] forKey:[NSNumber numberWithInteger:0]];
}

- (UIView *)addSnakeBodyWithColor:(UIColor *)color
{
    CGRect bodyFrame;
    CGRect snakeTailFrame = [self snakeTail].frame;
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
    UILabel *bodyLabel = [[UILabel alloc]initWithFrame:snakeBody.bounds];
    bodyLabel.backgroundColor = [UIColor clearColor];
    [snakeBody addSubview:bodyLabel];
    bodyLabel.textColor = [UIColor blackColor];
    bodyLabel.textAlignment = NSTextAlignmentCenter;
    bodyLabel.text = [NSString stringWithFormat:@"%d",_snakeLength];
    snakeBody.backgroundColor = color;
    snakeBody.tag = _snakeLength;
    [_snakeBody addObject:snakeBody];
    [_bodyDirections setObject:[NSNumber numberWithInt:direction] forKey:[NSNumber numberWithInteger:snakeBody.tag]];
    _snakeLength ++;

    return snakeBody;
}

- (MoveDirection)getBodyDirection:(UIView *)body
{
   return [[_bodyDirections objectForKey:[NSNumber numberWithInteger:body.tag]] intValue];
}

- (MoveDirection)headDirection
{
   return [[_bodyDirections objectForKey:[NSNumber numberWithInteger:0]] intValue];
}

- (UIView *)snakeHead
{
    return [_snakeBody firstObject];
}

- (UIView *)snakeTail
{
    return [_snakeBody lastObject];
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
    [_turningNodes setObject:[NSNumber numberWithInt:direction] forKey:[NSValue valueWithCGRect:[self snakeHead].frame]];
}

- (void)setTurningNodeWithDirection:(MoveDirection)direction
{
    [_turningNodes setObject:[NSNumber numberWithInt:direction] forKey:[NSValue valueWithCGRect:[self snakeHead].frame]];
}

- (BOOL)changeDirectionWithGameIsOver:(BOOL)gameIsOver moveTimer:(NSTimer *)timer
{
    MoveDirection direction;
    UIView *tail = [self snakeTail];
    
    for (UIView *view in _snakeBody) {
        
        NSValue *directionValue = [_turningNodes objectForKey:[NSValue valueWithCGRect:view.frame]];
        
        // If body frame = turning node frame , then there's a direction change
        if (directionValue) {
            direction = [[_turningNodes objectForKey:[NSValue valueWithCGRect:view.frame]] intValue];
            
            // Set new direction for body
            [_bodyDirections setObject:[NSNumber numberWithInt:direction] forKey:[NSNumber numberWithInteger:view.tag]];
            
            // Remove turning node if last body has passed the node
            if (view.tag == tail.tag) {
                [_turningNodes removeObjectForKey:[NSValue valueWithCGRect:view.frame]];
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
                    [timer invalidate];
                    NSLog(@"Game over");
                    gameIsOver  = YES;
                    break;
                }
            }
            
            if ([self touchedScreenBounds:newPosition]) {
                [timer invalidate];
                NSLog(@"Game over");
                gameIsOver  = YES;
            }
        }
        
        if (!gameIsOver)
            view.frame = newPosition;
        else
            return YES;
    }
    return NO;
}

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

- (BOOL)touchedScreenBounds:(CGRect)newPostion
{
    CGRect screen= [[UIScreen mainScreen]bounds];

    CGRect topBound = CGRectMake(0, -1, screen.size.width, 1);
    CGRect botBound = CGRectMake(0, screen.size.height+1, screen.size.width, 1);
    CGRect leftBound = CGRectMake(-1, 0, 1, screen.size.height);
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

- (void)updateTurningNode
{
    UIView *tail = [self snakeTail];
        
    NSValue *directionValue = [_turningNodes objectForKey:[NSValue valueWithCGRect:tail.frame]];
    
    // If body frame = turning node frame , then there's a direction change
    if (directionValue)
        [_turningNodes removeObjectForKey:[NSValue valueWithCGRect:tail.frame]];

}

@end
