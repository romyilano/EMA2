//
//  NLSUIKitExtras.h
//
//  Created by Patrick Piemonte on 2/2/14.
//  Copyright (c) 2014. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMAConstants.h"

// Colors

@interface UIColor (NLSUIKitExtras)

+ (UIColor *)greenLightNLSColor;
+ (UIColor *)greenNLSColor;
+ (UIColor *)greenDarkNLSColor;
+ (UIColor *)redNLSColor;
+ (UIColor *)pinkNLSColor;
+ (UIColor *)blueNLSColor;
+ (UIColor *)goldNLSColor;

+ (UIColor *)neonPurpleColor;
+ (UIColor *)neonPinkColor;
+ (UIColor *)neonGreenColor;
+ (UIColor *)neonMellowYellowColor;
+ (UIColor *)neonOrangeColor;
+ (UIColor *)neonLightBlueColor;

+ (UIColor *)neutralLightestColor;
+ (UIColor *)neutralLighterColor;
+ (UIColor *)neutralMediumColor;
+ (UIColor *)grayColor05;

@end

// Fonts

@interface UIFont (NLSUIKitExtras)

+ (UIFont *)NLSFontSize:(CGFloat)size;
//+ (UIFont *)fontSymbolSize:(CGFloat)size;

@end

@interface UIImage (NLSUIKitExtras)

/* public function that creates the actual image */
+ (UIImage *)fillImgOfSize:(CGSize)imgSize withColor:(UIColor*)imgColor;

@end

@interface UINavigationController (NLSUIKitExtras)

/* public function that creates the actual image */
+ (UINavigationController *)initStyled;

@end
