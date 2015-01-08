//
//  ZCExtension.h
//  ZombieConga
//
//  Created by Voronok Vitaliy on 1/8/15.
//  Copyright (c) 2015 IDPGroup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

//@interface CGGeometry (ZCExtension)
//
//
//@end

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
