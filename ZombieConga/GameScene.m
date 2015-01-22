//
//  GameScene.m
//  ZombieConga
//
//  Created by Voronok Vitaliy on 1/5/15.
//  Copyright (c) 2015 IDPGroup. All rights reserved.
//

#import "GameScene.h"

#import "CGGeometry+ZCExtension.h"

static const CGFloat zombieRotateRadiansPerSec = 4.0 * M_PI;

@interface GameScene ()
@property (nonatomic, strong)   SKSpriteNode    *zombie1;
@property (nonatomic, assign)   NSTimeInterval  lastUpdateTime;
@property (nonatomic, assign)   NSTimeInterval  dt;
@property (nonatomic, assign)   CGFloat         zombieMovePointsPerSec;
@property (nonatomic, assign)   CGPoint         velocity;
@property (nonatomic, assign)   CGRect          playableRect;
@property (nonatomic, assign)   CGPoint         lastTouchLocation;

- (void)sceneTouched:(CGPoint)touchLocation;
- (void)moveSprite:(SKSpriteNode *)sprite velocity:(CGPoint)velocity;
- (void)moveZombieToward:(CGPoint)location;
- (void)boundsCheckZombie;
- (void)rotateSprite:(SKSpriteNode *)sprite
           direction:(CGPoint)direction
 rotateRadiansPerSec:(CGFloat)radiansPerSec;

- (void)spawnEnemy;

@end

@implementation GameScene

#pragma mark -
#pragma mark Initialization and Dealocation

- (instancetype)initWithSize:(CGSize)size {
    CGFloat maxAspectRatio = 16.0 / 9.0;
    CGFloat playableHeight = size.width / maxAspectRatio;
    CGFloat playableMargin = (size.height - playableHeight) / 2;
    
    self.playableRect = CGRectMake(0, playableMargin, size.width, playableHeight);
    
    return [super initWithSize:size];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"init(coder:) has not been implemented"
                                 userInfo:nil];
    return nil;
}

#pragma mark -
#pragma mark Life Cycle

- (void)didMoveToView:(SKView *)view {
    [super didMoveToView:view];
    
    self.zombieMovePointsPerSec = 240;//480;
    self.velocity = CGPointZero;
    
    // Create sprite Background
    self.backgroundColor = [SKColor whiteColor];
    SKSpriteNode *background = [[SKSpriteNode alloc] initWithImageNamed:@"background1"];
    CGSize size = self.size;
    background.position = CGPointMake(size.width / 2, size.height / 2);
    background.zPosition = -1;
    
    [self addChild:background];
    
    // Create sprite zombie
    SKSpriteNode *zombie1 = [[SKSpriteNode alloc] initWithImageNamed:@"zombie1"];
    zombie1.position = CGPointMake(400, 400);
    self.zombie1 = zombie1;
    
    [self addChild:zombie1];
    
//    [self spawnEnemy];
    
    [self runAction:[SKAction repeatActionForever:[SKAction sequence:@[
                                                                       [SKAction runBlock:^{
                                                                            [self spawnEnemy];
                                                                        }],
                                                                       [SKAction waitForDuration:2]]] ]];

    
    [self debugDrawPlayableArea];
    NSLog(@"Size : (%@)", NSStringFromCGSize(background.size));
}

- (void)update:(NSTimeInterval)currentTime {
    [super update:currentTime];
    
    if (self.lastUpdateTime > 0) {
        self.dt = currentTime - self.lastUpdateTime;
    } else {
        self.dt = 0;
    }
    
    self.lastUpdateTime = currentTime;
//    NSLog(@"%f  milliseconds since last update", self.dt * 1000);
    SKSpriteNode *zombie1 = self.zombie1;

    CGPoint lastTouch = self.lastTouchLocation;
    
    if (!CGPointEqualToPoint(lastTouch, CGPointZero)) {
        CGPoint diff = CGSubtractionVectors(lastTouch, zombie1.position);
        
        if (CGLengthVector(diff) <= self.zombieMovePointsPerSec * self.dt) {
            zombie1.position = lastTouch;
            self.velocity = CGPointZero;
        } else {
            [self moveSprite:zombie1 velocity:self.velocity];
//            [self rotateSprite:zombie1 direction:self.velocity];
            [self rotateSprite:zombie1 direction:self.velocity rotateRadiansPerSec:zombieRotateRadiansPerSec];
        }
    }
    
    [self boundsCheckZombie];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self];
    self.lastTouchLocation = touchLocation;
    [self sceneTouched:touchLocation];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self];
    self.lastTouchLocation = touchLocation;
    [self sceneTouched:touchLocation];
}

#pragma mark -
#pragma mark Private

- (void)spawnEnemy {
    SKSpriteNode *enemy = [[SKSpriteNode alloc] initWithImageNamed:@"enemy"];
    
    CGSize size = self.size;
    CGSize enemySize = enemy.size;
    
    CGFloat min = CGRectGetMinY(self.playableRect) + size.height / 2;
    CGFloat max = CGRectGetMinY(self.playableRect) - size.height / 2;
    
    enemy.position = CGPointMake(size.width /* / 2 */ - enemySize.width / 2, CGFloatRandomInRange(min, max));
    
    [self addChild:enemy];
    
    SKAction *actionMove = [SKAction moveToX:(-size.width / 2) duration:2.0];
    
    [enemy runAction:actionMove];

    
//    CGPoint moveTo = CGPointMake(-enemy.size.width / 2, enemy.position.y);
//    SKAction *action = [SKAction moveTo:moveTo duration:2];

//    CGPoint pointMidMove = CGPointMake(size.width / 2, CGRectGetMinY(self.playableRect) + enemySize.height / 2);
////    SKAction *actionMidMove = [SKAction moveTo:pointMidMove duration:1.0];
//    SKAction *actionMidMove = [SKAction moveByX:(-(size.width / 2 - enemy.size.width / 2))
//                                              y:(-CGRectGetHeight(self.playableRect) / 2 + enemySize.height / 2)
//                                       duration:1];
//
//    CGPoint pointMove = CGPointMake(-enemySize.width / 2, enemy.position.y);
////    SKAction *actionMove = [SKAction moveTo:pointMove duration:1.0];
//    SKAction *actionMove = [SKAction moveByX:(-(size.width / 2 - enemySize.width / 2))
//                                           y:(CGRectGetHeight(self.playableRect) / 2 - enemySize.height / 2)
//                                    duration:1];
//
//    SKAction *reverseMid = [actionMidMove reversedAction];
//    SKAction *reverseMove = [actionMove reversedAction];
//    
//    SKAction *wait = [SKAction waitForDuration:0.25];
//    
//    SKAction *logMessage = [SKAction runBlock:^{
//        NSLog(@"Reached bottom!");
//    }];
//    
////    SKAction *sequence = [SKAction sequence:@[actionMidMove, logMessage, wait, actionMove, wait, reverseMove, wait, reverseMid]];
// 
//    SKAction *halfSequence = [SKAction sequence:@[actionMidMove, logMessage, wait, actionMove, wait]];
//    SKAction *sequence = [SKAction sequence:@[halfSequence, halfSequence.reversedAction]];
//    
//    SKAction *repeate = [SKAction repeatActionForever:sequence];
//    
//    [enemy runAction:repeate];
}

- (void)sceneTouched:(CGPoint)touchLocation {
    [self moveZombieToward:touchLocation];
}

- (void)moveSprite:(SKSpriteNode *)sprite velocity:(CGPoint)velocity {
    CGPoint amountToMove = CGMultiplicationVectorOnScalar(velocity, self.dt);
    
    NSLog(@"Amount to move: %@", NSStringFromCGPoint(amountToMove));

    sprite.position = CGAdditionVectors(sprite.position, amountToMove);
}

- (void)moveZombieToward:(CGPoint)location {
    SKSpriteNode *zombie = self.zombie1;
    CGFloat zombieMovePointsPerSec = self.zombieMovePointsPerSec;
    
    CGPoint offset = CGSubtractionVectors(location, zombie.position);
    
    CGPoint direction = CGNormalizedVector(offset);
    self.velocity = CGMultiplicationVectorOnScalar(direction, zombieMovePointsPerSec);
}

- (void)rotateSprite:(SKSpriteNode *)sprite
           direction:(CGPoint)direction
 rotateRadiansPerSec:(CGFloat)radiansPerSec
{
    CGFloat angle = CGShortestAngleBetween(sprite.zRotation, CGAngleVector(direction));
    CGFloat amountToRotate = fmin(radiansPerSec * self.dt, fabs(angle));
    sprite.zRotation += CGSign(angle) * amountToRotate;
}

- (void)boundsCheckZombie {
    CGPoint bottomLeft = CGPointMake(0, CGRectGetMinY(self.playableRect));
    CGPoint topRight = CGPointMake(self.size.width, CGRectGetMaxY(self.playableRect));
    
    SKSpriteNode *zombie = self.zombie1;
    
    if (zombie.position.x <= bottomLeft.x) {
        zombie.position = CGPointMake(bottomLeft.x, zombie.position.y);
        self.velocity = CGPointMake(-self.velocity.x, self.velocity.y);
    }
    
    if (zombie.position.x >= topRight.x) {
        zombie.position = CGPointMake(topRight.x, zombie.position.y);
        self.velocity = CGPointMake(-self.velocity.x, self.velocity.y);
    }
    
    if (zombie.position.y <= bottomLeft.y) {
        zombie.position = CGPointMake(zombie.position.x, bottomLeft.y);
        self.velocity = CGPointMake(self.velocity.x, -self.velocity.y);
    }
    
    if (zombie.position.y >= topRight.y) {
        zombie.position = CGPointMake(zombie.position.x, topRight.y);
        self.velocity = CGPointMake(self.velocity.x, -self.velocity.y);
    }
}

- (void)rotateSprite:(SKSpriteNode *)sprite direction:(CGPoint)direction {
    sprite.zRotation = CGAngleVector(direction);
}

- (void)debugDrawPlayableArea {
    SKShapeNode *shape = [SKShapeNode node];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, nil, self.playableRect);
    shape.path = path;
    shape.strokeColor = [SKColor redColor];
    shape.lineWidth = 14;
    
    [self addChild:shape];
}

@end
