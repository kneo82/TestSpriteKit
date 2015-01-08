//
//  GameScene.m
//  ZombieConga
//
//  Created by Voronok Vitaliy on 1/5/15.
//  Copyright (c) 2015 IDPGroup. All rights reserved.
//

#import "GameScene.h"

@interface GameScene ()
@property (nonatomic, strong)   SKSpriteNode    *zombie1;
@property (nonatomic, assign)   NSTimeInterval  lastUpdateTime;
@property (nonatomic, assign)   NSTimeInterval  dt;
@property (nonatomic, assign)   CGFloat         zombieMovePointsPerSec;
@property (nonatomic, assign)   CGPoint         velocity;
@property (nonatomic, assign)   CGRect          playableRect;

- (void)sceneTouched:(CGPoint)touchLocation;
- (void)moveSprite:(SKSpriteNode *)sprite velocity:(CGPoint)velocity;
- (void)moveZombieToward:(CGPoint)location;
- (void)boundsCheckZombie;

@end

@implementation GameScene

#pragma mark -
#pragma mark Initialization and Dealocation

- (instancetype)initWithSize:(CGSize)size {
    CGFloat maxAspectRatio = 16.0 / 9.0;
    CGFloat playableHeight = size.width / maxAspectRatio;
    CGFloat playableMargin = (size.height- playableHeight) / 2;
    
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
    NSLog(@"%f  milliseconds since last update", self.dt * 1000);
    SKSpriteNode *zombie1 = self.zombie1;
    
    [self moveSprite:zombie1 velocity:self.velocity];
    
    [self boundsCheckZombie];
    
    [self rotateSprite:zombie1 direction:self.velocity];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self];
    [self sceneTouched:touchLocation];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self];
    [self sceneTouched:touchLocation];
}

#pragma mark -
#pragma mark Private

- (void)sceneTouched:(CGPoint)touchLocation {
    [self moveZombieToward:touchLocation];
}

- (void)moveSprite:(SKSpriteNode *)sprite velocity:(CGPoint)velocity {
    CGFloat dt = self.dt;
    CGPoint amountToMove = CGPointMake(velocity.x * dt, velocity.y * dt);
    
    NSLog(@"Amount to move: %@", NSStringFromCGPoint(amountToMove));
    
    CGPoint position = sprite.position;
    sprite.position = CGPointMake(position.x + amountToMove.x, position.y + amountToMove.y);
}

- (void)moveZombieToward:(CGPoint)location {
    SKSpriteNode *zombie = self.zombie1;
    CGPoint position = zombie.position;
    CGFloat zombieMovePointsPerSec = self.zombieMovePointsPerSec;
    
    CGPoint offset = CGPointMake(location.x - position.x, location.y - position.y);
    
    double length = sqrt(offset.x * offset.x + offset.y * offset.y);
    
    CGPoint direction = CGPointMake(offset.x / length, offset.y / length);
    self.velocity = CGPointMake(direction.x * zombieMovePointsPerSec, direction.y * zombieMovePointsPerSec);
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
    sprite.zRotation = atan2(direction.y, direction.x);
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
