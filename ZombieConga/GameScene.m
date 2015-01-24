//
//  GameScene.m
//  ZombieConga
//
//  Created by Voronok Vitaliy on 1/5/15.
//  Copyright (c) 2015 IDPGroup. All rights reserved.
//

#import "GameScene.h"

#import "CGGeometry+ZCExtension.h"

static const CGFloat zombieRotateRadiansPerSec  = 4.0 * M_PI;
static NSString * const kZCAnimationKey         = @"animation";
static NSString * const kZCCatSpriteName        = @"cat";
static NSString * const kZCEnemySpriteName      = @"enemy";

@interface GameScene ()
@property (nonatomic, strong)   SKSpriteNode    *zombie1;
@property (nonatomic, assign)   NSTimeInterval  lastUpdateTime;
@property (nonatomic, assign)   NSTimeInterval  dt;
@property (nonatomic, assign)   CGFloat         zombieMovePointsPerSec;
@property (nonatomic, assign)   CGPoint         velocity;
@property (nonatomic, assign)   CGRect          playableRect;
@property (nonatomic, assign)   CGPoint         lastTouchLocation;
@property (nonatomic, strong)   SKAction        *zombieAnimation;
@property (nonatomic, readonly)   SKAction        *catCollisionSound;
@property (nonatomic, readonly)   SKAction        *enemyCollisionSound;

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

@synthesize catCollisionSound = _catCollisionSound;
@synthesize enemyCollisionSound = _enemyCollisionSound;

- (SKAction *)catCollisionSound {
    if (!_catCollisionSound) {
        _catCollisionSound = [SKAction playSoundFileNamed:@"hitCat.wav" waitForCompletion:NO];
    }
    
    return  _catCollisionSound;
}

- (SKAction *)enemyCollisionSound {
    if (!_enemyCollisionSound) {
        _enemyCollisionSound = [SKAction playSoundFileNamed:@"hitCatLady.wav" waitForCompletion:NO];
    }
    
    return  _enemyCollisionSound;
}

#pragma mark -
#pragma mark Initialization and Dealocation

- (instancetype)initWithSize:(CGSize)size {
    CGFloat maxAspectRatio = 16.0 / 9.0;
    CGFloat playableHeight = size.width / maxAspectRatio;
    CGFloat playableMargin = (size.height - playableHeight) / 2;
    
    self.playableRect = CGRectMake(0, playableMargin, size.width, playableHeight);
    
    NSMutableArray *textures = [NSMutableArray array];
    
    for (NSUInteger index = 1; index <= 4; index++) {
        [textures addObject:[SKTexture textureWithImageNamed:[NSString stringWithFormat:@"zombie%lu", (unsigned long)index]]];
    }
    
    [textures addObject:textures[3]];
    [textures addObject:textures[2]];
    
    self.zombieAnimation = [SKAction repeatActionForever:[SKAction animateWithTextures:textures
                                                                          timePerFrame:0.1]];
    
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
    
    self.zombieMovePointsPerSec = 240;
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
    
    // Spawn enemy
    [self runAction:[SKAction repeatActionForever:[SKAction sequence:@[
                                                                       [SKAction runBlock:^{
                                                                            [self spawnEnemy];
                                                                        }],
                                                                       [SKAction waitForDuration:4]]] ]];

    // Spawn cats
    [self runAction:[SKAction repeatActionForever:[SKAction sequence:@[[SKAction runBlock:^{
                                                                                            [self spawnCat];
                                                                                        }],
                                                                       [SKAction waitForDuration:1]]]]];
    
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
    SKSpriteNode *zombie1 = self.zombie1;

    CGPoint lastTouch = self.lastTouchLocation;
    
    if (!CGPointEqualToPoint(lastTouch, CGPointZero)) {
        CGPoint diff = CGSubtractionVectors(lastTouch, zombie1.position);
        
        if (CGLengthVector(diff) <= self.zombieMovePointsPerSec * self.dt) {
            zombie1.position = lastTouch;
            self.velocity = CGPointZero;
            
            [self stopZombieAnimation];
        } else {
            [self moveSprite:zombie1 velocity:self.velocity];
            [self rotateSprite:zombie1 direction:self.velocity rotateRadiansPerSec:zombieRotateRadiansPerSec];
        }
    }
    
    [self boundsCheckZombie];
//    [self checkCollisions];
}

- (void)didEvaluateActions {
    [super didEvaluateActions];
    
    [self checkCollisions];
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

- (void)zombieHitCat:(SKSpriteNode *)cat {
    [self runAction:self.catCollisionSound];

    [cat removeFromParent];
}

- (void)zombieHitEnemy:(SKSpriteNode *)enemy {
    [self runAction:self.enemyCollisionSound];
    
    [enemy removeFromParent];
}

- (void)checkCollisions {
    NSMutableArray *hitCats = [NSMutableArray array];
    
    [self enumerateChildNodesWithName:kZCCatSpriteName usingBlock:^(SKNode *node, BOOL *stop) {
        SKSpriteNode *cat = (SKSpriteNode *)node;
        
        if (CGRectIntersectsRect(cat.frame, self.zombie1.frame)) {
            [hitCats addObject:cat];
        }
    }];
    
    for (SKSpriteNode *cat in hitCats) {
        [self zombieHitCat:cat];
    }
    
    NSMutableArray *hitEnemies = [NSMutableArray array];
    
    [self enumerateChildNodesWithName:kZCEnemySpriteName usingBlock:^(SKNode *node, BOOL *stop) {
        SKSpriteNode *enemy = (SKSpriteNode *)node;
        
        if (CGRectIntersectsRect(CGRectInset(node.frame, 20, 20), self.zombie1.frame)) {
            [hitEnemies addObject:enemy];
        }
    }];
    
    for (SKSpriteNode *enemy in hitEnemies) {
        [self zombieHitEnemy:enemy];
    }
}

- (void)spawnCat {
    SKSpriteNode *cat = [[SKSpriteNode alloc] initWithImageNamed:kZCCatSpriteName];
    CGRect rect = self.playableRect;
    
    CGFloat x= CGFloatRandomInRange(CGRectGetMinX(rect), CGRectGetMaxX(rect));
    CGFloat y= CGFloatRandomInRange(CGRectGetMinY(rect), CGRectGetMaxY(rect));
    
    cat.position = CGPointMake(x, y);
    [cat setScale:0];
    
    cat.name = kZCCatSpriteName;
    
    [self addChild:cat];
    
    cat.zRotation = - M_PI / 16.0;
    
    SKAction *scaleUp = [SKAction scaleBy:1.2 duration:0.25];
    SKAction *scaleDown = [scaleUp reversedAction];
    SKAction *fullScale = [SKAction sequence:@[scaleUp, scaleDown, scaleUp, scaleDown]];

    SKAction *leftWiggle = [SKAction rotateByAngle:(M_PI / 8) duration:0.5];
    SKAction *rightWiggle = [leftWiggle reversedAction];
    SKAction *fullWiggle = [SKAction sequence:@[leftWiggle, rightWiggle]];
//    SKAction *wiggleWait = [SKAction repeatAction:fullWiggle count:10];
    
    SKAction *group = [SKAction group:@[fullScale, fullWiggle]];
    SKAction *groupWait = [SKAction repeatAction:group count:10];
    
    SKAction *appear = [SKAction scaleTo:1 duration:.5];
//    SKAction *wait = [SKAction waitForDuration:10];
    SKAction *disappear = [SKAction scaleTo:0 duration:.5];
    SKAction *removeFromParent = [SKAction removeFromParent];
    
    NSArray *actions = @[appear, groupWait, disappear, removeFromParent];
    
    
    [cat runAction:[SKAction sequence:actions]];
}

- (void)spawnEnemy {
    SKSpriteNode *enemy = [[SKSpriteNode alloc] initWithImageNamed:@"enemy"];
    
    CGSize size = self.size;
    CGSize enemySize = enemy.size;
    
    CGFloat min = CGRectGetMinY(self.playableRect) + enemySize.height / 2;
    CGFloat max = CGRectGetMaxY(self.playableRect) - enemySize.height / 2;
    
    enemy.position = CGPointMake(size.width - enemySize.width / 2, CGFloatRandomInRange(min, max));
    
    enemy.name = kZCEnemySpriteName;
    
    [self addChild:enemy];
    
    SKAction *actionMove = [SKAction moveToX:(-enemySize.width / 2) duration:4.0];
    
    SKAction *actionRemove = [SKAction removeFromParent];
    [enemy runAction:[SKAction sequence:@[actionMove, actionRemove]]];

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
    [self startZombieAnimation];
    
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

- (void)startZombieAnimation {
    if (![self.zombie1 actionForKey:kZCAnimationKey]) {
        [self.zombie1 runAction:[SKAction repeatActionForever:self.zombieAnimation] withKey:kZCAnimationKey];
    }
}

- (void)stopZombieAnimation {
    [self.zombie1 removeActionForKey:kZCAnimationKey];
}

@end
