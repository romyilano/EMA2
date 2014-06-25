//
//  NLSGeometry.h
//
//  Created by Patrick Piemonte on 2/2/14.
//  Copyright (c) 2014. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CGBase.h>
#import <math.h> // <tgmath.h>

#pragma mark - Foundation

NS_INLINE NSInteger clampi(NSInteger x, NSInteger low, NSInteger high)
{
	if (x < low) x = low;
	if (x > high) x = high;
	return x;
}

NS_INLINE float clampf(float x, float low, float high)
{
	if (x < low) x = low;
	if (x > high) x = high;
	return x;
}

NS_INLINE double clamp(double x, double low, double high)
{
	if (x < low) x = low;
	if (x > high) x = high;
	return x;
}

#pragma mark - CoreGraphics

CG_INLINE CGFloat CGFloat_clamp(CGFloat x, CGFloat low, CGFloat high)
{
	if (x < low) x = low;
	if (x > high) x = high;
	return x;
}

CG_INLINE CGFloat CGFloat_lerp(CGFloat t, CGFloat a, CGFloat b)
{
	return (a + t * (b - a));
}

CG_INLINE CGFloat CGFloat_fabs(CGFloat cgfloat) {
#if defined(__LP64__) && __LP64__
    return fabs(cgfloat);
#else
    return fabsf(cgfloat);
#endif
}

CG_INLINE CGFloat CGFloat_sqrt(CGFloat cgfloat) {
#if defined(__LP64__) && __LP64__
    return sqrt(cgfloat);
#else
    return sqrtf(cgfloat);
#endif
}

CG_INLINE CGFloat CGFloat_ceil(CGFloat cgfloat) {
#if defined(__LP64__) && __LP64__
    return ceil(cgfloat);
#else
    return ceilf(cgfloat);
#endif
}

CG_INLINE CGFloat CGFloat_floor(CGFloat cgfloat) {
#if defined(__LP64__) && __LP64__
    return floor(cgfloat);
#else
    return floorf(cgfloat);
#endif
}

CG_INLINE CGFloat CGFloat_nearbyint(CGFloat cgfloat) {
#if defined(__LP64__) && __LP64__
    return nearbyint(cgfloat);
#else
    return nearbyintf(cgfloat);
#endif
}

CG_INLINE CGFloat CGFloat_rint(CGFloat cgfloat) {
#if defined(__LP64__) && __LP64__
    return rint(cgfloat);
#else
    return rintf(cgfloat);
#endif
}

CG_INLINE CGFloat CGFloat_round(CGFloat cgfloat) {
#if defined(__LP64__) && __LP64__
    return round(cgfloat);
#else
    return roundf(cgfloat);
#endif
}

#pragma mark - CGPoint

CG_INLINE CGFloat CGPointMagnitude(const CGPoint point)
{
    return CGFloat_sqrt( (point.x * point.x) + (point.y * point.y) );
}

#pragma mark - CGRect

CG_INLINE CGRect CGIntegralRect(const CGRect rect)
{
    CGRect integralRect;
    integralRect.size.width = CGFloat_rint(rect.size.width);
    integralRect.size.height = CGFloat_rint(rect.size.height);
    integralRect.origin.x = CGFloat_rint(rect.origin.x);
    integralRect.origin.y = CGFloat_rint(rect.origin.y);
    return integralRect;
}

#pragma mark -

CG_INLINE CGFloat rubberBandValueForValue(CGFloat newValue, CGFloat minValue, CGFloat maxValue, CGFloat range)
{
    maxValue = MAX(minValue, maxValue);
    
    if (newValue > maxValue) {
    
        CGFloat unit = (newValue - maxValue) / range;
        CGFloat d = 0.7f * unit + 1.0f;
        newValue = ( (1.0f - (1.0f / d)) * range) + maxValue;
    
    } else if (newValue < minValue) {
    
        CGFloat unit = (minValue - newValue) / range;
        CGFloat d = 0.7f * unit + 1.0f;
        newValue = minValue - ( (1.0f - (1.0f / d)) * range);
    
    }
    
    return newValue;
}
