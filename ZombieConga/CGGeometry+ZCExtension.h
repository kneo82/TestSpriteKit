//
//  ZCExtension.h
//  ZombieConga
//
//  Created by Voronok Vitaliy on 1/8/15.
//  Copyright (c) 2015 IDPGroup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

#define DEGREES_TO_RADIANS(__ANGLE__) ((__ANGLE__) * 0.01745329252f) // PI / 180
#define RADIANS_TO_DEGREES(__ANGLE__) ((__ANGLE__) * 57.29577951f) // PI * 180

/**
 *  Operator |+| 
 *  Vector -> CGPoint - (x, y)
 *  vector = CGAdditionVectors(vector1, vector2) -> vector = vector1 + vector2
 */
CG_INLINE
CGPoint CGAdditionVectors(CGPoint vector1, CGPoint vector2) {
    return CGPointMake(vector1.x + vector2.x, vector1.y + vector2.y);
}

/**
 *  Operator |-|
 *  Vector -> CGPoint - (x, y)
 *  vector = CGSubtractionVectors(vector1, vector2) -> vector = vector1 - vector2
 */
CG_INLINE
CGPoint CGSubtractionVectors(CGPoint vector1, CGPoint vector2) {
    return CGPointMake(vector1.x - vector2.x, vector1.y - vector2.y);
}

/**
 *  Operator |*|
 *  Vector -> CGPoint -> (x, y)
 *  vector = CGMultiplicationVectors(vector1, vector2) -> vector = vector1 * vector2
 */
CG_INLINE
CGPoint CGMultiplicationVectors(CGPoint vector1, CGPoint vector2) {
    return CGPointMake(vector1.x * vector2.x, vector1.y * vector2.y);
}

/**
 *  Operator |*|
 *  Vector -> CGPoint -> (x, y)
 *  vector = CGMultiplicationVectorOnScalar(vector1, scalar) -> vector = vector1 * scalar
 */
CG_INLINE
CGPoint CGMultiplicationVectorOnScalar(CGPoint vector, CGFloat scalar) {
    return CGPointMake(vector.x * scalar, vector.y * scalar);
}

/**
 *  Operator |/|
 *  Vector -> CGPoint -> (x, y)
 *  vector = CGDivisionVectors(vector1, vector2) -> vector = vector1 / vector2
 */
CG_INLINE
CGPoint CGDivisionVectors(CGPoint vector1, CGPoint vector2) {
    return CGPointMake(vector1.x / vector2.x, vector1.y / vector2.y);
}

/**
 *  Operator |/|
 *  Vector -> CGPoint -> (x, y)
 *  vector = CGMultiplicationVectorOnScalar(vector1, scalar) -> vector = vector1 / scalar
 */
CG_INLINE
CGPoint CGDivisionVectorOnScalar(CGPoint vector, CGFloat scalar) {
    return CGPointMake(vector.x / scalar, vector.y / scalar);
}

CG_INLINE
CGFloat CGLengthVector(CGPoint vector) {
    return sqrt(vector.x * vector.x + vector.y * vector.y);
}

CG_INLINE
CGPoint CGNormalizedVector(CGPoint vector) {
    return CGDivisionVectorOnScalar(vector, CGLengthVector(vector));
}

CG_INLINE
CGFloat CGAngleVector(CGPoint vector) {
    return atan2(vector.y, vector.x);
}

CG_INLINE
CGFloat CGShortestAngleBetween(CGFloat angle1, CGFloat angle2) {
    CGFloat twoPi = M_PI * 2.0;
    CGFloat angle = fmod((angle2 - angle1), twoPi);
    
    if (angle >= M_PI) {
        angle = angle - twoPi;
    }
    
    if (angle <= -M_PI) {
        angle = angle + twoPi;
    }
    
    return angle;
}

CG_INLINE
CGFloat CGSign(CGFloat value) {
    return value >= 0.0 ? 1.0 : -1.0;
}

CG_INLINE
CGFloat CGFloatRandom() {
    return ((CGFloat)arc4random()) / ((CGFloat)UINT32_MAX);
}

CG_INLINE
CGFloat CGFloatRandomInRange(CGFloat min, CGFloat max) {
    return CGFloatRandom() * (max - min) + min;
}



