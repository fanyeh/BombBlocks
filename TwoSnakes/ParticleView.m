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
    SKAction *moveSound;
    SKAction *introMoveSound;
    SKAction *comboSound;
    SKAction *breakSound;
    SKAction *buttonSound;
    SKAction *gameoverSound;
    SKAction *explodeSound;
    SKAction *explodeColorSound;
    SKAction *explodeSquareSound;
    SKAction *gameSound;
    SKAction *scanSound;
    SKAction *tickSound;
    SKAction *sirenSound;
    SKAction *menuBombDropSound;
    SKAction *randomBombSound;
}

-(id)initWithSize:(CGSize)size {
    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        self.backgroundColor = [SKColor colorWithCGColor:[UIColor clearColor].CGColor];
        moveSound       =  [SKAction playSoundFileNamed:@"introMove.mp3" waitForCompletion:NO];
        introMoveSound = [SKAction playSoundFileNamed:@"introMove.mp3" waitForCompletion:NO];
        comboSound =[SKAction playSoundFileNamed:@"combo.mp3" waitForCompletion:NO];
        breakSound =[SKAction playSoundFileNamed:@"break.mp3" waitForCompletion:NO];
        buttonSound =[SKAction playSoundFileNamed:@"button.mp3" waitForCompletion:NO];
        gameoverSound =[SKAction playSoundFileNamed:@"gameover.wav" waitForCompletion:NO];
        explodeSound =[SKAction playSoundFileNamed:@"explode.mp3" waitForCompletion:NO];
        explodeColorSound=[SKAction playSoundFileNamed:@"explodeColor.mp3" waitForCompletion:NO];
        explodeSquareSound= [SKAction playSoundFileNamed:@"explodeSquare.mp3" waitForCompletion:NO];
        gameSound=[SKAction playSoundFileNamed:@"playButtonSound.mp3" waitForCompletion:NO];
        scanSound=[SKAction playSoundFileNamed:@"scanSound.mp3" waitForCompletion:NO];
        tickSound=[SKAction playSoundFileNamed:@"tickSound.mp3" waitForCompletion:NO];
        sirenSound= [SKAction playSoundFileNamed:@"sirenSound.mp3" waitForCompletion:NO];
        menuBombDropSound=[SKAction playSoundFileNamed:@"menuBombDropSound.mp3" waitForCompletion:NO];
        randomBombSound=[SKAction playSoundFileNamed:@"randomBombSound.mp3" waitForCompletion:NO];

    }
    return self;
}

-(id)init
{
    if (self = [super init]) {
        
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
    }
    emitter.position = CGPointMake(posX, posY);
    emitter.particleColor =  color;
    emitter.particleColorBlendFactor = 1.0;
    emitter.particleColorSequence = nil;
    [emitter resetSimulation];
    [self addChild:emitter];
}

-(void)playSound:(SoundType)soundType
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"sound"]) {
        
        switch (soundType) {
            case kSoundTypeMoveSound:
                [self runAction:moveSound];
                break;
                
            case  kSoundTypeIntroMoveSound:
                [self runAction: introMoveSound];
                break;
                
            case kSoundTypeComboSound:
                [self runAction:comboSound ];
                break;
                
            case kSoundTypeBreakSound:
                [self runAction: breakSound];
                break;
                
            case kSoundTypeButtonSound:
                [self runAction: buttonSound];
                break;
                
            case kSoundTypeGameoverSound:
                [self runAction:gameoverSound];
                break;
                
            case kSoundTypeExplodeSound:
                [self runAction: explodeSound];
                break;
                
            case kSoundTypeExplodeColorSound:
                [self runAction: explodeColorSound];
                break;
                
            case kSoundTypeExplodeSquareSound:
                [self runAction: explodeSquareSound];
                break;
                
            case kSoundTypeGameSound:
                [self runAction:gameSound];
                break;
                
            case  kSoundTypeScanSound:
                [self runAction: scanSound];
                break;
                
            case  kSoundTypeTickSound:
                [self runAction: tickSound];
                break;
                
            case kSoundTypeSirenSound:
                [self runAction:sirenSound];
                break;
                
            case kSoundTypeMenuBombDropSound:
                [self runAction:menuBombDropSound];
                break;
                
            case kSoundTypeRandomBombSound:
                [self runAction: randomBombSound];
                break;
        }
    }
}

@end
