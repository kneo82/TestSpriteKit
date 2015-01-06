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

@end

@implementation GameScene

- (void)didMoveToView:(SKView *)view {
    self.backgroundColor = [SKColor whiteColor];
    SKSpriteNode *background = [[SKSpriteNode alloc] initWithImageNamed:@"background1"];
    
    // Set position sprite Background
    CGSize size = self.size;
    background.position = CGPointMake(size.width / 2, size.height / 2);
//    background.anchorPoint = CGPointZero;
//    background.position = CGPointZero;
    
//    background.zRotation = M_PI / 8;
    
    background.zPosition = -1;
    
    [self addChild:background];
    
    // Create sprite zombie
    SKSpriteNode *zombie1 = [[SKSpriteNode alloc] initWithImageNamed:@"zombie1"];
    zombie1.position = CGPointMake(400, 400);
    
    self.zombie1 = zombie1;
    
    [self addChild:zombie1];
    
    NSLog(@"Size : (%@)", NSStringFromCGSize(background.size));
}

@end
