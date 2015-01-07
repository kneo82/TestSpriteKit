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

@end

@implementation GameScene

- (void)didMoveToView:(SKView *)view {
    [super didMoveToView:view];
    
    self.zombieMovePointsPerSec = 480;
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
//    zombie1.position = CGPointMake(zombie1.position.x + 4, zombie1.position.y);
    
    [self moveSprite:zombie1 velocity:CGPointMake(self.zombieMovePointsPerSec, 0)];
}

- (void)moveSprite:(SKSpriteNode *)sprite velocity:(CGPoint)velocity {
    CGFloat dt = self.dt;
    CGPoint amountToMove = CGPointMake(velocity.x * dt, velocity.y * dt);
    
    NSLog(@"Amount to move: %@", NSStringFromCGPoint(amountToMove));
    
    CGPoint position = sprite.position;
    sprite.position = CGPointMake(position.x + amountToMove.x, position.y + amountToMove.y);
}

@end
