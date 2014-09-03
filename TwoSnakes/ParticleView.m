//
//  ParticleView.m
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/6/23.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import "ParticleView.h"

@implementation ParticleView
{
    CAEmitterLayer* fireEmitter;
}

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        self.backgroundColor = [SKColor colorWithCGColor:[UIColor clearColor].CGColor];

    }
    return self;
}

- (void)newExplosionWithPosX:(float)posX
                     andPosY:(float)posY
                   assetType:(AssetType)type
{
    SKEmitterNode *emitter;
    UIColor *color;
    
    switch (type) {
        case kAssetTypeBlue:
            emitter = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"BlueParticle"ofType:@"sks"]];
            color = BlueDotColor;
            break;
        case kAssetTypeRed:
            emitter = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"RedParticle"ofType:@"sks"]];
            color = RedDotColor;
            break;
        case kAssetTypeGreen:
            emitter = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"GreenParticle"ofType:@"sks"]];
            color = GreenDotColor;
            break;
        case kAssetTypeYellow:
            emitter = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"YellowParticle"ofType:@"sks"]];
            color = YellowDotColor;
            break;
        case kAssetTypeGrey:
            emitter = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"GreyParticle"ofType:@"sks"]];
            color = GreyDotColor;
            break;
        case kAssetTypeOrange:
            emitter = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"OrangeParticle"ofType:@"sks"]];
            color = OrangeDotColor;
            break;
    }
    emitter.position = CGPointMake(posX, posY);
    emitter.particleColor =  color;
    emitter.particleColorBlendFactor = 1.0;
    emitter.particleColorSequence = nil;
    [emitter resetSimulation];
    [self addChild:emitter];
}

- (void)playMoveSound
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"sound"])
            [self runAction:[SKAction playSoundFileNamed:@"move.mp3" waitForCompletion:NO]];
}

- (void)playComboSound
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"sound"])
        [self runAction:[SKAction playSoundFileNamed:@"combo.mp3" waitForCompletion:NO]];
}

- (void)playButtonSound
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"sound"])
        [self runAction:[SKAction playSoundFileNamed:@"button.mp3" waitForCompletion:NO]];
}

- (void)playGameoverSound
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"sound"])
        [self runAction:[SKAction playSoundFileNamed:@"gameover.wav" waitForCompletion:NO]];
}

@end
